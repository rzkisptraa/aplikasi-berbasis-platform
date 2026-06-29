<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {

    public function up(): void
    {
        Schema::create(
            'notifications',
            function (
                Blueprint $table
            ) {

                $table->id();

                $table->foreignId(
                    'user_id'
                )
                ->constrained(
                    'users'
                )
                ->cascadeOnDelete();

                $table->string(
                    'title'
                );

                $table->text(
                    'message'
                );

                $table->string(
                    'type'
                )->default(
                    'ORDER'
                );

                // READ STATUS
                $table->boolean(
                    'is_read'
                )->default(
                    false
                );

                $table->timestamp(
                    'read_at'
                )->nullable();

                /* EXTRA DATA */
                $table->json(
                    'data'
                )->nullable();

                $table->timestamps();
            }
        );
    }

    public function down(): void
    {
        Schema::dropIfExists(
            'notifications'
        );
    }
};