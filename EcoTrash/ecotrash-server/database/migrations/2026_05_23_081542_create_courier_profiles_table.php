<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {

    public function up(): void
    {
        Schema::create('courier_profiles', function (Blueprint $table) {

            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->onDelete('cascade');

            /* Vehicle */

            $table->string('vehicle_type');
            $table->string('vehicle_plate');

            /* Identity Verification */

            $table->string('ktp_number');
            $table->string('ktp_photo');

            $table->string('sim_number');
            $table->string('sim_photo');

            $table->string('face_photo');

            /* Address */

            $table->text('address');
            $table->string('city');
            $table->string('province');

            /* Metrics */

            $table->decimal(
                'rating',
                3,
                2
            )->default(0);

            $table->boolean(
                'is_verified'
            )->default(false);

            /* Realtime Location */

            $table->decimal(
                'current_latitude',
                10,
                7
            )->nullable();

            $table->decimal(
                'current_longitude',
                10,
                7
            )->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists(
            'courier_profiles'
        );
    }
};