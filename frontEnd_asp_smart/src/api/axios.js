import axios from 'axios'
import { toast } from 'sonner'
export const api = axios.create({ baseURL: import.meta.env.VITE_API_URL || '/api', withCredentials: true, withXSRFToken: true, headers: { Accept: 'application/json' } })
export async function csrf() { const root = api.defaults.baseURL.replace(/\/api\/?$/, ''); await axios.get(`${root}/sanctum/csrf-cookie`, { withCredentials: true }) }
api.interceptors.response.use(r => r, error => {
  const status = error.response?.status
  const messages = { 401: 'Silakan masuk kembali.', 403: 'Anda tidak memiliki izin untuk tindakan ini.', 404: 'Data tidak ditemukan.', 409: 'Data berubah atau permintaan sudah diproses.', 419: 'Sesi berakhir. Muat ulang halaman.', 422: 'Periksa kembali data formulir.', 429: 'Terlalu banyak permintaan. Coba sesaat lagi.', 500: 'Terjadi kesalahan saat memproses transaksi.' }
  error.userMessage = status === 422 ? Object.values(error.response?.data?.errors || {}).flat().join(' ') || error.response?.data?.message : (status < 500 && error.response?.data?.message) || messages[status] || 'Tidak dapat menghubungi server.'
  if (error.config?.method !== 'get') toast.error(error.userMessage)
  if (status === 401) window.dispatchEvent(new Event('auth-expired'))
  return Promise.reject(error)
})
export async function download(url, params, name) { const r = await api.get(url, { params, responseType: 'blob' }); const object = URL.createObjectURL(r.data); const a = document.createElement('a'); a.href = object; a.download = name; a.click(); setTimeout(() => URL.revokeObjectURL(object), 1000) }
