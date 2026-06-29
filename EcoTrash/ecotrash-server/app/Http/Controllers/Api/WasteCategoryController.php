<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WasteCategory;
use Illuminate\Http\Request;

class WasteCategoryController extends Controller
{
    /*GET ALL*/
    public function index()
    {
        $categories = WasteCategory::where(
            'is_active',
            true
        )->get();

        return response()->json([
            'data' => $categories
        ]);
    }

    /*STORE*/
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price_per_kg' => 'required|numeric|min:0',
        ]);

        $category = WasteCategory::create([
            'name' => $validated['name'],
            'description' =>
                $validated['description']
                ?? null,
            'price_per_kg' =>
                $validated['price_per_kg'],
            'is_active' => true,
        ]);

        return response()->json([
            'message' => 'Waste category created',
            'data' => $category
        ], 201);
    }

    /*UPDATE*/
    public function update(
        Request $request,
        string $id
    ) {
        $category = WasteCategory::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'price_per_kg' => 'sometimes|numeric|min:0',
            'is_active' => 'sometimes|boolean',
        ]);

        $category->update($validated);

        return response()->json([
            'message' => 'Waste category updated',
            'data' => $category
        ]);
    }

    /*DELETE*/
    public function destroy(string $id)
    {
        $category =
            WasteCategory::findOrFail($id);

        $category->delete();

        return response()->json([
            'message' =>
                'Waste category deleted'
        ]);
    }

    public function show(string $id)
    {
        $category =
            WasteCategory::findOrFail($id);

        return response()->json([
            'data' => $category
        ]);
    }
}

