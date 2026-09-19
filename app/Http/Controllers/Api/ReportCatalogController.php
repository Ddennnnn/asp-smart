<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReportCatalogService;
use App\Services\SettingService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use OpenSpout\Common\Entity\Row;
use OpenSpout\Writer\XLSX\Writer;

class ReportCatalogController extends Controller
{
    public function catalog(Request $r, ReportCatalogService $s)
    {
        Gate::authorize('report.view');

        return collect($s->catalog())->reject(fn ($name, $key) => $key === 'audit' && ! $r->user()->hasPermission('audit.view'));
    }

    public function index(Request $r, ReportCatalogService $s)
    {
        $d = $s->dataset($r);

        return ['title' => $d['title'], 'columns' => $d['columns'], 'current_snapshot' => $d['current_snapshot'], 'rows' => $d['query']->orderBy('id')->paginate(25)->through(fn ($row) => $s->display((array) $row, $d['columns']))];
    }

    public function export(Request $r, ReportCatalogService $s)
    {
        Gate::authorize('report.export');
        $r->validate(['format' => 'required|in:xlsx,pdf']);
        $d = $s->dataset($r);
        $q = $d['query']->orderBy('id');
        if ($r->input('format') === 'pdf') {
            abort_if((clone $q)->count() > 2000, 422, 'Persempit filter untuk PDF (maksimal 2.000 baris).');

            return Pdf::loadView('report-table', ['title' => $d['title'], 'columns' => $d['columns'], 'rows' => $q->get()->map(fn ($row) => $s->display((array) $row, $d['columns'])), 'business' => SettingService::get('business', []), 'user' => $r->user(), 'from' => $r->input('from'), 'to' => $r->input('to'), 'snapshot' => $d['current_snapshot']])->setPaper('a4', 'landscape')->download('laporan.pdf');
        }$path = tempnam(storage_path('app/private'), 'report-');
        $w = new Writer;
        $w->openToFile($path);
        $w->addRow(Row::fromValues(array_values($d['columns'])));
        foreach ($q->lazy(500) as $row) {
            $w->addRow(Row::fromValues(array_values($s->display((array) $row, $d['columns']))));
        }$w->close();

        return response()->download($path, 'laporan.xlsx', ['Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'])->deleteFileAfterSend(true);
    }
}
