import { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { Eye } from 'lucide-react'
import { api } from '../api/axios'
import { Button, Modal } from './ui'

export default function AccountReveal({ account }) {
  const [open, setOpen] = useState(false)
  const reveal = useMutation({ mutationFn: () => api.get(`/accounts/${account.id}/reveal`).then(r => r.data.account_number) })
  return <><Button type="button" variant="ghost" aria-label={`Lihat nomor ${account.name}`} onClick={() => { setOpen(true); reveal.mutate() }}><Eye size={16}/></Button><Modal open={open} onOpenChange={value => { setOpen(value); if (!value) reveal.reset() }} title={account.name} description="Akses nomor rekening lengkap tercatat dalam jejak audit.">{reveal.isPending ? <p>Memuat nomor rekening…</p> : reveal.isError ? <p className="error-text">Nomor rekening tidak dapat ditampilkan.</p> : <p className="account-number">{reveal.data || 'Nomor rekening belum diisi.'}</p>}</Modal></>
}
