<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();

            $table->foreignId('wallet_id')
                ->constrained('wallets')
                ->cascadeOnDelete();

            $table->enum('type', [
                'CREDIT',
                'DEBIT',
                'WITHDRAW',
                'REFUND'
            ]);

            $table->decimal(
                'amount',
                12,
                2
            );

            $table->text('description')
                ->nullable();

            $table->string('status')
                ->default('SUCCESS');

            $table->foreignId('reference_order_id')
                ->nullable()
                ->constrained('orders')
                ->nullOnDelete();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_transactions');
    }
};