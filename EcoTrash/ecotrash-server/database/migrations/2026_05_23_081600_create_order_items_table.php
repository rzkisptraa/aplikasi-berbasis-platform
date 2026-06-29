<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();

            $table->foreignId('order_id')
                ->constrained('orders')
                ->cascadeOnDelete();

            $table->foreignId('waste_category_id')
                ->constrained('waste_categories')
                ->cascadeOnDelete();

            $table->decimal(
                'estimated_weight',
                10,
                2
            )->nullable();

            $table->decimal(
                'actual_weight',
                10,
                2
            )->nullable();

            $table->decimal(
                'price_per_kg',
                10,
                2
            );

            $table->decimal(
                'subtotal',
                10,
                2
            )->default(0);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};