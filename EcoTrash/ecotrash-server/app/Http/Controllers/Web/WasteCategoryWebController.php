<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\WasteCategory;
use Illuminate\Http\Request;

class WasteCategoryWebController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->search;

        $categories = WasteCategory::query()
            ->when($search, function ($query) use ($search) {
                $query->where('name', 'like', '%' . $search . '%')
                    ->orWhere('description', 'like', '%' . $search . '%');
            })
            ->latest()
            ->paginate(10);

        return view('waste-categories.index', compact('categories', 'search'));
    }

    public function create()
    {
        return view('waste-categories.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:waste_categories,name',
            'description' => 'nullable|string',
            'price_per_kg' => 'required|numeric|min:0',
            'is_active' => 'required|boolean',
        ]);

        WasteCategory::create([
            'name' => $request->name,
            'description' => $request->description,
            'price_per_kg' => $request->price_per_kg,
            'is_active' => $request->is_active,
        ]);

        return redirect()
            ->route('waste-categories.index')
            ->with('success', 'Kategori sampah berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $category = WasteCategory::findOrFail($id);
        return view('waste-categories.edit', compact('category'));
    }

    public function update(Request $request, $id)
    {
        $category = WasteCategory::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255|unique:waste_categories,name,' . $category->id,
            'description' => 'nullable|string',
            'price_per_kg' => 'required|numeric|min:0',
            'is_active' => 'required|boolean',
        ]);

        $category->update([
            'name' => $request->name,
            'description' => $request->description,
            'price_per_kg' => $request->price_per_kg,
            'is_active' => $request->is_active,
        ]);

        return redirect()
            ->route('waste-categories.index')
            ->with('success', 'Kategori sampah berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $category = WasteCategory::findOrFail($id);
        $category->delete();

        return redirect()
            ->route('waste-categories.index')
            ->with('success', 'Kategori sampah berhasil dihapus.');
    }
}
