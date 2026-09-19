<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use App\Services\SettingService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Writer\XLSX\Writer;

class ReportController extends Controller
{
    public function dashboard(Request $r, ReportService $s)
    {
        Gate::authorize('dashboard.view');

        return $s->summary($r);
    }

    public function index(Request $r, ReportService $s)
    {
        Gate::authorize('report.view');

        return ['summary' => $s->summary($r), 'transactions' => $s->transactions($r)->with('branch', 'creator')->latest('id')->paginate(25)->through(fn ($t) => $t->only(['reference_number', 'type', 'status', 'amount', 'revenue', 'cost', 'profit', 'created_at']) + ['branch_name' => $t->branch->name, 'cashier' => $t->creator->name])];
    }

    public function export(Request $r, ReportService $s)
    {
        Gate::authorize('report.export');
        $r->validate(['format' => 'required|in:xlsx,pdf']);
        $q = $s->transactions($r)->with('branch', 'creator')->orderBy('id');
        if ($r->input('format') === 'pdf') {
            abort_if((clone $q)->count() > 2000, 422, 'Persempit periode laporan PDF (maksimal 2.000 baris).');

            return Pdf::loadView('report', ['rows' => $q->get(), 'summary' => $s->summary($r), 'business' => SettingService::get('business', []), 'user' => $r->user(), 'from' => $r->input('from'), 'to' => $r->input('to')])->setPaper('a4', 'landscape')->download('laporan.pdf');
        }
        $path = tempnam(storage_path('app/private'), 'report-');
        $writer = new Writer;
        $writer->openToFile($path);
        $writer->addRow(Row::fromValues(['Referensi', 'Cabang', 'Kasir', 'Jenis', 'Status', 'Nominal', 'Pendapatan', 'Biaya', 'Laba', 'Waktu']));
        foreach ($q->lazyById(500) as $t) {
            $writer->addRow(Row::fromValues([$t->reference_number, $t->branch->name, $t->creator->name, __('counter.'.$t->type), __('counter.'.$t->status), $t->amount, $t->revenue, $t->cost, $t->profit, $t->created_at->toDateTimeString()]));
        }
        $writer->close();

        return response()->download($path, 'laporan.xlsx', ['Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'])->deleteFileAfterSend(true);
    }
}
