<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();

            $table->string('order_code')
                ->unique();

            $table->foreignId('seller_id')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->foreignId('courier_id')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            $table->foreignId('seller_address_id')
                ->constrained('seller_addresses')
                ->cascadeOnDelete();

            $table->enum('status', [
                'PENDING',
                'ACCEPTED',
                'PICKED_UP',
                'DELIVERED',
                'COMPLETED',
                'CANCELLED'
            ])->default('PENDING');

            $table->string('pickup_photo')
                ->nullable();

            $table->decimal(
                'estimated_total_weight',
                10,
                2
            )->nullable();

            $table->decimal(
                'actual_total_weight',
                10,
                2
            )->nullable();

            $table->decimal(
                'estimated_total_price',
                10,
                2
            )->default(0);

            $table->decimal(
                'total_price',
                10,
                2
            )->default(0);

            $table->text('pickup_notes')
                ->nullable();

            $table->text('cancel_reason')
                ->nullable();

            $table->decimal(
                'latitude',
                10,
                7
            );

            $table->decimal(
                'longitude',
                10,
                7
            );

            $table->timestamp('picked_up_at')
                ->nullable();

            $table->timestamp('delivered_at')
                ->nullable();

            $table->timestamp('completed_at')
                ->nullable();

            $table->timestamp('cancelled_at')
                ->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};