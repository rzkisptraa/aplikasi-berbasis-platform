<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /*Run the migrations.*/
    public function up(): void
{
    Schema::create(
        'reviews',
        function (
            Blueprint $table
        ) {

            $table->id();

            // RELATION
            $table->foreignId(
                'seller_id'
            )
            ->constrained(
                'users'
            )
            ->cascadeOnDelete();

            $table->foreignId(
                'courier_id'
            )
            ->constrained(
                'users'
            )
            ->cascadeOnDelete();

            $table->foreignId(
                'order_id'
            )
            ->unique()
            ->constrained(
                'orders'
            )
            ->cascadeOnDelete();

            // REVIEW
            $table->unsignedTinyInteger(
                'rating'
            );

            $table->text(
                'comment'
            )->nullable();

            $table->timestamps();
        }
    );
}

    /*Reverse the migrations.*/
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
