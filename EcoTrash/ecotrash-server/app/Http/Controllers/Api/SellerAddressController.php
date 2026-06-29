<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SellerAddress;
use Illuminate\Http\Request;

class SellerAddressController extends Controller
{
    /*GET ALL USER ADDRESS*/
    public function index(Request $request)
    {
        $addresses = SellerAddress::where(
            'seller_id',
            $request->user()->id
        )->get();

        return response()->json([
            'data' => $addresses
        ]);
    }

    /*SHOW DETAIL*/
    public function show(
        Request $request,
        string $id
    ) {
        $address = SellerAddress::where(
            'seller_id',
            $request->user()->id
        )->findOrFail($id);

        return response()->json([
            'data' => $address
        ]);
    }

    /*STORE*/
    public function store(Request $request)
    {
        $validated = $request->validate([
            'label' => 'required|string|max:100',
            'address' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'is_default' => 'nullable|boolean',
        ]);

        if (
            isset($validated['is_default']) &&
            $validated['is_default']
        ) {
            SellerAddress::where(
                'seller_id',
                $request->user()->id
            )->update([
                'is_default' => false
            ]);
        }

        $address = SellerAddress::create([
            'seller_id' =>
                $request->user()->id,
            'label' =>
                $validated['label'],
            'address' =>
                $validated['address'],
            'latitude' =>
                $validated['latitude'],
            'longitude' =>
                $validated['longitude'],
            'is_default' =>
                $validated['is_default']
                ?? false,
        ]);

        return response()->json([
            'message' =>
                'Address created',
            'data' => $address
        ], 201);
    }

    /*UPDATE*/
    public function update(
        Request $request,
        string $id
    ) {
        $address = SellerAddress::where(
            'seller_id',
            $request->user()->id
        )->findOrFail($id);

        $validated = $request->validate([
            'label' => 'sometimes|string|max:100',
            'address' => 'sometimes|string',
            'latitude' => 'sometimes|numeric',
            'longitude' => 'sometimes|numeric',
            'is_default' => 'sometimes|boolean',
        ]);

        if (
            isset($validated['is_default']) &&
            $validated['is_default']
        ) {
            SellerAddress::where(
                'seller_id',
                $request->user()->id
            )->update([
                'is_default' => false
            ]);
        }

        $address->update($validated);

        return response()->json([
            'message' =>
                'Address updated',
            'data' => $address
        ]);
    }

    /*DELETE*/
    public function destroy(
        Request $request,
        string $id
    ) {
        $address = SellerAddress::where(
            'seller_id',
            $request->user()->id
        )->findOrFail($id);

        $address->delete();

        return response()->json([
            'message' =>
                'Address deleted'
        ]);
    }
}