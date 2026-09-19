import { flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Button, Empty } from './ui'
export default function DataTable({ columns, data = [], meta, onPage }) {
  // eslint-disable-next-line react-hooks/incompatible-library -- React Compiler is not enabled; TanStack v8 is used without memoization.
  const table = useReactTable({ data, columns, getCoreRowModel: getCoreRowModel(), manualPagination: true })
  if (!data.length) return <Empty/>
  return <><div className="table-wrap"><table><thead>{table.getHeaderGroups().map(group => <tr key={group.id}>{group.headers.map(h => <th key={h.id}>{flexRender(h.column.columnDef.header, h.getContext())}</th>)}</tr>)}</thead><tbody>{table.getRowModel().rows.map(row => <tr key={row.id}>{row.getVisibleCells().map(cell => <td key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</td>)}</tr>)}</tbody></table></div>{meta && <div className="pagination"><span>{meta.total} data · Halaman {meta.current_page} dari {meta.last_page}</span><div><Button variant="outline" disabled={meta.current_page <= 1} onClick={() => onPage(meta.current_page - 1)} aria-label="Halaman sebelumnya"><ChevronLeft size={16}/></Button><Button variant="outline" disabled={meta.current_page >= meta.last_page} onClick={() => onPage(meta.current_page + 1)} aria-label="Halaman berikutnya"><ChevronRight size={16}/></Button></div></div>}</>
}
