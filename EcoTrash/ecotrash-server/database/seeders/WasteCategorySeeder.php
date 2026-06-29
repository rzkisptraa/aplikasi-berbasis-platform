<?php

namespace Database\Seeders;

use App\Models\WasteCategory;
use Illuminate\Database\Seeder;

class WasteCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [

            [
                'name' => 'Plastik',
                'description' => 'Sampah plastik rumah tangga',
                'price_per_kg' => 3000,
            ],

            [
                'name' => 'Kertas',
                'description' => 'Kertas bekas dan arsip',
                'price_per_kg' => 2000,
            ],

            [
                'name' => 'Kardus',
                'description' => 'Kardus bekas',
                'price_per_kg' => 2500,
            ],

            [
                'name' => 'Besi',
                'description' => 'Logam besi bekas',
                'price_per_kg' => 7000,
            ],

            [
                'name' => 'Aluminium',
                'description' => 'Aluminium bekas',
                'price_per_kg' => 10000,
            ],

            [
                'name' => 'Botol Kaca',
                'description' => 'Botol kaca bekas',
                'price_per_kg' => 1500,
            ],

            [
                'name' => 'Elektronik Ringan',
                'description' => 'Elektronik kecil',
                'price_per_kg' => 12000,
            ],

        ];

        foreach ($categories as $category) {

            WasteCategory::updateOrCreate(
                ['name' => $category['name']],
                [
                    'description' => $category['description'],
                    'price_per_kg' => $category['price_per_kg'],
                    'is_active' => true,
                ]
            );
        }
    }
}