import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Plus, Pencil, Search, Upload } from 'lucide-react'
import { toast } from 'sonner'
import { api } from '../api/axios'
import { useApp, allowed } from '../stores/app'
import { Button, Modal, Field, MoneyInput, SelectResource, State } from '../components/ui'
import DataTable from '../components/DataTable'
import AccountReveal from '../components/AccountReveal'
import { rupiah, label } from '../utils/format'

export function ResourceForm({ resource, definition, row, done }) {
  const client = useQueryClient(), branch = useApp(s => s.branch)
  const schema = z.object(Object.fromEntries(Object.entries(definition.fields).map(([key, f]) => [key, f.type === 'boolean' ? z.boolean() : f.rules.startsWith('required') ? z.union([z.string().min(1, 'Wajib diisi'), z.number()]) : z.any().optional()])))
  const defaults = Object.fromEntries(Object.entries(definition.fields).map(([key, f]) => [key, row?.[key] ?? (key === 'branch_id' ? branch : f.type === 'boolean' ? !['is_main', 'is_central'].includes(key) : ['money', 'number'].includes(f.type) ? '0' : '')]))
  const { control, register, handleSubmit, setError, formState: { errors } } = useForm({ defaultValues: defaults, resolver: zodResolver(schema) })
  const save = useMutation({ mutationFn: async values => { const d = Object.fromEntries(Object.entries(values).map(([k, v]) => [k, v === '' ? null : v])); return row ? api.put(`/resources/${resource}/${row.id}`, d) : api.post(`/resources/${resource}`, d) }, onSuccess: () => { client.invalidateQueries(); toast.success('Data berhasil disimpan.'); done() }, onError: e => Object.entries(e.response?.data?.errors || {}).forEach(([k, v]) => setError(k, { message: v[0] })) })
  return <form onSubmit={handleSubmit(v => save.mutate(v))}><div className="form-grid">{Object.entries(definition.fields).filter(([key]) => !(row && key === 'opening_balance')).map(([key, f]) => <Field key={key} label={f.label} error={errors[key]?.message}>{f.type === 'select' ? <Controller name={key} control={control} render={({ field }) => <SelectResource {...field} source={f.source} required={f.rules.startsWith('required')} />}/> : f.type === 'money' ? <Controller name={key} control={control} render={({ field }) => <MoneyInput {...field}/>}/> : f.type === 'choice' ? <select {...register(key)}><option value="">Pilih…</option>{Object.entries(f.options).map(([k, name]) => <option value={k} key={k}>{name}</option>)}</select> : f.type === 'boolean' ? <input type="checkbox" {...register(key)}/> : f.type === 'textarea' ? <textarea {...register(key)} rows={4}/> : f.type === 'image' ? <Controller name={key} control={control} render={({ field }) => <ImageUpload value={field.value} onChange={field.onChange}/>}/> : <input className="input" type={f.type} {...register(key)}/>}</Field>)}</div><div className="form-footer"><Button type="button" variant="outline" onClick={done}>Batal</Button><Button disabled={save.isPending}>{save.isPending ? 'Menyimpan…' : 'Simpan data'}</Button></div></form>
}
export function ImageUpload({ value, onChange }) { const [busy, setBusy] = useState(false); return <div>{value && <img src={value} className="upload-preview" alt="Pratinjau"/>}<label className="upload"><Upload size={18}/>{busy ? 'Mengunggah…' : 'Pilih gambar'}<input type="file" accept="image/png,image/jpeg,image/webp" disabled={busy} onChange={async e => { if (!e.target.files[0]) return; setBusy(true); const d = new FormData(); d.append('file', e.target.files[0]); try { const r = await api.post('/uploads', d); onChange(r.data.url) } finally { setBusy(false) } }}/></label></div> }
export default function ResourcePage() {
  const { resource } = useParams(), { auth, branch } = useApp(), [page, setPage] = useState(1), [search, setSearch] = useState(''), [edit, setEdit] = useState(null)
  const meta = useQuery({ queryKey: ['metadata'], queryFn: () => api.get('/metadata').then(r => r.data) }), d = meta.data?.[resource]
  const q = useQuery({ queryKey: ['resources', resource, branch, page, search], queryFn: () => api.get(`/resources/${resource}`, { params: { branch_id: branch || undefined, page, search } }).then(r => r.data), enabled: !!d })
  const fields = Object.entries(d?.fields || {}).filter(([k]) => !['account_number', 'notes', 'description', 'image', 'content'].includes(k)).slice(0, 7)
  const columns = fields.map(([key, f]) => ({ accessorKey: key, header: f.label, cell: ({ row }) => f.type === 'money' ? rupiah(row.original[key]) : f.type === 'boolean' ? row.original[key] ? 'Ya' : 'Tidak' : row.original[`${key}_label`] || f.options?.[row.original[key]] || label(row.original[key]) }))
  if (resource === 'branches') columns.push({ id: 'detail', header: '', cell: ({ row }) => <Link className="text-button" to={`/app/branches/${row.original.id}`}>Detail cabang →</Link> })
  if (resource === 'financial-accounts') columns.push({ accessorKey: 'current_balance', header: 'Saldo saat ini', cell: i => <strong>{rupiah(i.getValue())}</strong> }, { accessorKey: 'account_number_masked', header: 'Nomor rekening' })
  if (resource === 'financial-accounts' && allowed(auth, 'account.reveal')) columns.push({ id: 'reveal', header: '', cell: ({ row }) => <AccountReveal account={row.original}/> })
  if (d && allowed(auth, `${d.permission}.update`)) columns.push({ id: 'edit', header: '', cell: ({ row }) => <Button variant="ghost" onClick={() => setEdit(row.original)} aria-label={`Edit ${row.original.name || d.label}`}><Pencil size={16}/></Button> })
  return <State query={meta}>{d ? <><div className="page-heading"><div><span className="eyebrow">DATA MASTER</span><h1>{d.label}</h1><p>Kelola data usaha Anda dalam satu tempat.</p></div>{allowed(auth, `${d.permission}.create`) && <Button onClick={() => setEdit({})}><Plus size={17}/>Tambah data</Button>}</div><div className="panel"><div className="panel-toolbar"><div className="search"><Search size={17}/><input aria-label="Cari data" placeholder={`Cari ${d.label.toLowerCase()}…`} value={search} onChange={e => { setSearch(e.target.value); setPage(1) }}/></div></div><State query={q}><DataTable data={q.data?.data} columns={columns} meta={q.data} onPage={setPage}/></State></div><Modal open={!!edit} onOpenChange={v => !v && setEdit(null)} title={`${edit?.id ? 'Edit' : 'Tambah'} ${d.label}`}>{edit && <ResourceForm key={edit.id || 'new'} row={edit.id ? edit : null} resource={resource} definition={d} done={() => setEdit(null)}/>}</Modal></> : <p>Anda tidak memiliki akses modul ini.</p>}</State>
}
