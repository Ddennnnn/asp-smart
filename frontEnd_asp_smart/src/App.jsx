import { lazy, Suspense } from 'react'
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'sonner'
import AppLayout, { RequirePermission } from './layouts/AppLayout'
const Auth=lazy(()=>import('./pages/Auth'))
const PublicSite=lazy(()=>import('./pages/PublicSite'))
const Dashboard=lazy(()=>import('./pages/Dashboard'))
const ResourcePage=lazy(()=>import('./pages/ResourcePage'))
const TransactionForm=lazy(()=>import('./pages/TransactionForm'))
const Pos=lazy(()=>import('./pages/Pos'))
const Transactions=lazy(()=>import('./pages/Transactions'))
const Receipt=lazy(()=>import('./pages/Transactions').then(m=>({default:m.Receipt})))
const Operations=lazy(()=>import('./pages/Operations'))
const Reports=lazy(()=>import('./pages/Reports'))
const Settings=lazy(()=>import('./pages/Settings'))
const Users=lazy(()=>import('./pages/Settings').then(m=>({default:m.Users})))
const Finance=lazy(()=>import('./pages/Finance'))
const ReportCenter=lazy(()=>import('./pages/ReportCenter'))
const Roles=lazy(()=>import('./pages/Roles'))
const StockOpnames=lazy(()=>import('./pages/StockOpnames'))
const StockTransfers=lazy(()=>import('./pages/StockTransfers'))
const BranchDetail=lazy(()=>import('./pages/BranchDetail'))
const client=new QueryClient({defaultOptions:{queries:{staleTime:30000,retry:1,refetchOnWindowFocus:true},mutations:{retry:false}}})
const guard=(permission,children)=><RequirePermission permission={permission}>{children}</RequirePermission>
const transactionPermissions={digital:'digital.create',cash_withdrawal:'cash_withdrawal.create',money_transfer:'transfer.create',account_transfer:'account.transfer',adjustment:'account.adjust',expense:'expense.create',income:'income.create',stock_adjustment:'stock.adjust',stock_transfer:'stock.transfer'}
export default function App(){return <QueryClientProvider client={client}><BrowserRouter><Suspense fallback={<div className="skeleton-group"><div className="skeleton"/><div className="skeleton"/></div>}><Routes><Route path="/" element={<PublicSite/>}/><Route path="/login" element={<Auth/>}/><Route path="/forgot-password" element={<Auth mode="forgot"/>}/><Route path="/reset-password" element={<Auth mode="reset"/>}/><Route path="/app" element={<AppLayout/>}><Route index element={guard('dashboard.view',<Dashboard/>)}/><Route path="pos" element={guard('sale.create',<Pos key="sale"/>)}/><Route path="purchase" element={guard('purchase.create',<Pos key="purchase" purchase/>)}/><Route path="manage/:resource" element={<ResourcePage/>}/>{Object.entries(transactionPermissions).map(([type,p])=><Route key={type} path={`new/${type}`} element={guard(p,<TransactionForm key={type} kind={type}/>)}/>)}<Route path="transactions" element={guard('sale.view',<Transactions/>)}/><Route path="transactions/:id" element={guard('sale.view',<Receipt/>)}/>{Object.entries({'risk-flags':'approval.approve',ledger:'account.view',stock:'stock.view','stock-movements':'stock.view',reconciliations:'account.reconcile','cashier-sessions':'session.manage',approvals:'approval.approve',audit:'audit.view'}).map(([resource,p])=><Route key={resource} path={resource} element={guard(p,<Operations key={resource} resource={resource}/>)}/>)}{Object.entries({wallets:'wallet.manage',payables:'payable.manage',receivables:'receivable.manage','daily-closings':'report.view'}).map(([kind,p])=><Route key={kind} path={kind} element={guard(p,<Finance key={kind} kind={kind}/>)}/>)}<Route path="stock-opnames" element={guard('stock.opname',<StockOpnames/>)}/><Route path="stock-transfers" element={guard('stock.transfer',<StockTransfers/>)}/><Route path="branches/:id" element={guard('branch.view',<BranchDetail/>)}/><Route path="report-center" element={guard('report.view',<ReportCenter/>)}/><Route path="roles" element={guard('users.manage',<Roles/>)}/><Route path="reports" element={guard('report.view',<Reports/>)}/><Route path="settings" element={guard('settings.view',<Settings/>)}/><Route path="users" element={guard('users.manage',<Users/>)}/></Route><Route path="*" element={<div className="empty"><h1>Halaman tidak ditemukan</h1><Link to="/app">Kembali ke dashboard</Link></div>}/></Routes></Suspense></BrowserRouter><Toaster richColors position="top-right" closeButton/></QueryClientProvider>}
