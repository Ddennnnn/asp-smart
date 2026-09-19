import { useState } from 'react'
import * as Dialog from '@radix-ui/react-dialog'
import * as AlertDialog from '@radix-ui/react-alert-dialog'
import { Slot } from '@radix-ui/react-slot'
import { cva } from 'class-variance-authority'
import { clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'
import { X, Search, Check, ChevronDown, Loader2, PackageOpen, AlertCircle } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { NumericFormat } from 'react-number-format'
import { api } from '../api/axios'
import { label } from '../utils/format'
const styles = cva('btn', { variants: { variant: { default: 'btn-primary', outline: 'btn-outline', ghost: 'btn-ghost', danger: 'btn-danger' } }, defaultVariants: { variant: 'default' } })
export function Button({ asChild, variant, className, ...props }) { const Comp = asChild ? Slot : 'button'; return <Comp className={twMerge(clsx(styles({ variant }), className))} {...props} /> }
export function Modal({ open, onOpenChange, title, description = 'Lengkapi informasi di bawah ini.', children }) { return <Dialog.Root open={open} onOpenChange={onOpenChange}><Dialog.Portal><Dialog.Overlay className="overlay"/><Dialog.Content className="modal"><div className="modal-heading"><div><Dialog.Title>{title}</Dialog.Title><Dialog.Description>{description}</Dialog.Description></div><Dialog.Close asChild><Button variant="ghost" aria-label="Tutup"><X size={20}/></Button></Dialog.Close></div>{children}</Dialog.Content></Dialog.Portal></Dialog.Root> }
export function Confirm({ children, title, description, onConfirm, busy }) { return <AlertDialog.Root><AlertDialog.Trigger asChild>{children}</AlertDialog.Trigger><AlertDialog.Portal><AlertDialog.Overlay className="overlay"/><AlertDialog.Content className="modal confirm"><AlertDialog.Title>{title}</AlertDialog.Title><AlertDialog.Description>{description}</AlertDialog.Description><div className="actions"><AlertDialog.Cancel asChild><Button variant="outline">Batal</Button></AlertDialog.Cancel><AlertDialog.Action asChild><Button disabled={busy} onClick={onConfirm}>Ya, lanjutkan</Button></AlertDialog.Action></div></AlertDialog.Content></AlertDialog.Portal></AlertDialog.Root> }
export function MoneyInput({ value, onChange, ...props }) { return <NumericFormat className="input" value={value} thousandSeparator="." decimalSeparator="," prefix="Rp " decimalScale={2} allowNegative={false} valueIsNumericString onValueChange={v => onChange(v.value)} {...props}/> }
export function Field({ label: text, error, children, hint }) { return <label className="field"><span>{text}</span>{children}{hint && <small>{hint}</small>}{error && <small className="error-text">{error}</small>}</label> }
export function State({ query, children }) { if (query.isPending) return <div className="skeleton-group" aria-label="Memuat"><div className="skeleton"/><div className="skeleton"/><div className="skeleton"/></div>; if (query.isError) return <div className="empty error"><AlertCircle/><h3>Data belum dapat dimuat</h3><p>{query.error.userMessage || query.error.message}</p><Button variant="outline" onClick={() => query.refetch()}>Coba lagi</Button></div>; return children }
export function Empty({ title = 'Belum ada data', description = 'Data yang Anda simpan akan tampil di sini.' }) { return <div className="empty"><PackageOpen size={34}/><h3>{title}</h3><p>{description}</p></div> }
export function Badge({ value }) { return <span className={`badge badge-${value}`}>{label(value)}</span> }
export function SelectResource({ source, value, onChange, branch, filter, placeholder = 'Pilih…', required }) {
  const [open, setOpen] = useState(false), [search, setSearch] = useState('')
  const query = useQuery({ queryKey: ['options', source, branch, search], queryFn: () => api.get(`/resources/${source}`, { params: { per_page: 100, branch_id: branch || undefined, search } }).then(r => r.data) })
  const [picked, setPicked] = useState(null)
  const rows = query.data?.data?.filter(r => r.is_active !== false && (!filter || filter(r))) || [], selected = rows.find(r => String(r.id) === String(value)) || (String(picked?.id) === String(value) ? picked : null)
  return <div className="combobox"><Button type="button" variant="outline" className="select-trigger" role="combobox" aria-expanded={open} onClick={() => setOpen(!open)}>{selected?.name || selected?.account_name || placeholder}<ChevronDown size={15}/></Button>{open && <div className="select-popover"><div className="search"><Search size={16}/><input aria-label="Cari pilihan" value={search} onChange={e => setSearch(e.target.value)} placeholder="Ketik untuk mencari…"/></div>{query.isPending && <Loader2 className="spin"/>}{query.isError && <p>Gagal memuat pilihan.</p>}<div className="select-options">{!required && <button type="button" onClick={() => { onChange(''); setOpen(false) }}>Tanpa pilihan</button>}{rows.map(r => <button key={r.id} type="button" onClick={() => { onChange(String(r.id)); setPicked(r); setOpen(false) }}><span>{r.name || r.account_name}{r.branch_id_label && <small>{r.branch_id_label}</small>}</span>{String(value) === String(r.id) && <Check size={14}/>}</button>)}{!rows.length && !query.isPending && <p>Tidak ada pilihan.</p>}</div><button type="button" className="select-close" onClick={() => setOpen(false)}>Tutup pilihan</button></div>}</div>
}
