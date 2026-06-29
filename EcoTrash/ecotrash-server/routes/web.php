<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Web\WebAuthController;
use App\Http\Controllers\Web\AdminDashboardWebController;
use App\Http\Controllers\Web\CourierWebController;
use App\Http\Controllers\Web\OrderWebController;
use App\Http\Controllers\Web\WithdrawalWebController;
use App\Http\Controllers\Web\AdminManagementWebController;
use App\Http\Controllers\Web\WasteCategoryWebController;


/*
|--------------------------------------------------------------------------
| Guest Routes
|--------------------------------------------------------------------------
*/

Route::middleware('guest')
    ->group(function () {

        Route::get(
            '/login',
            [
                WebAuthController::class,
                'loginPage'
            ]
        )->name('login');

        Route::post(
            '/login',
            [
                WebAuthController::class,
                'login'
            ]
        );
    });

/*
|--------------------------------------------------------------------------
| Auth Routes
|--------------------------------------------------------------------------
*/

Route::middleware('auth')
    ->group(function () {

        /*
        |--------------------------------------------------------------------------
        | Dashboard
        |--------------------------------------------------------------------------
        */
        Route::get(
            '/',
            [
                AdminDashboardWebController::class,
                'index'
            ]
        )->name('dashboard');

        /*
        |--------------------------------------------------------------------------
        | Couriers
        |--------------------------------------------------------------------------
        */

        Route::prefix('couriers')
            ->name('couriers.')
            ->group(function () {

                Route::get(
                    '/',
                    [
                        CourierWebController::class,
                        'index'
                    ]
                )->name('index');

                Route::get(
                    '/create',
                    [
                        CourierWebController::class,
                        'create'
                    ]
                )->name('create');

                Route::post(
                    '/store',
                    [
                        CourierWebController::class,
                        'store'
                    ]
                )->name('store');

                Route::get(
                    '/{id}',
                    [
                        CourierWebController::class,
                        'show'
                    ]
                )->name('show');

                Route::get(
                    '/{id}/edit',
                    [
                        CourierWebController::class,
                        'edit'
                    ]
                )->name('edit');

                Route::post(
                    '/{id}/update',
                    [
                        CourierWebController::class,
                        'update'
                    ]
                )->name('update');

                Route::post(
                    '/{id}/toggle-status',
                    [
                        CourierWebController::class,
                        'toggleStatus'
                    ]
                )->name('toggle-status');

                Route::post(
                    '/{id}/fire',
                    [
                        CourierWebController::class,
                        'fire'
                    ]
                )->name('fire');
            });
        /*
        |--------------------------------------------------------------------------
        | Orders
        |--------------------------------------------------------------------------
        */
        Route::get(
            '/orders',
            [
                OrderWebController::class,
                'index'
            ]
        )->name('orders');

        Route::get(
            '/orders/{id}',
            [
                OrderWebController::class,
                'show'
            ]
        )->name('orders.show');

        /*
        |--------------------------------------------------------------------------
        | Withdrawals
        |--------------------------------------------------------------------------
        */

        Route::get(
            '/withdrawals',
            [
                WithdrawalWebController::class,
                'index'
            ]
        )->name('withdrawals');

        /*
        |--------------------------------------------------------------------------
        | Waste Categories
        |--------------------------------------------------------------------------
        */
        Route::prefix('waste-categories')
            ->name('waste-categories.')
            ->group(function () {

                Route::get(
                    '/',
                    [
                        WasteCategoryWebController::class,
                        'index'
                    ]
                )->name('index');

                Route::get(
                    '/create',
                    [
                        WasteCategoryWebController::class,
                        'create'
                    ]
                )->name('create');

                Route::post(
                    '/store',
                    [
                        WasteCategoryWebController::class,
                        'store'
                    ]
                )->name('store');

                Route::get(
                    '/{id}/edit',
                    [
                        WasteCategoryWebController::class,
                        'edit'
                    ]
                )->name('edit');

                Route::post(
                    '/{id}/update',
                    [
                        WasteCategoryWebController::class,
                        'update'
                    ]
                )->name('update');

                Route::post(
                    '/{id}/delete',
                    [
                        WasteCategoryWebController::class,
                        'destroy'
                    ]
                )->name('destroy');
            });

        /*
        |--------------------------------------------------------------------------
        | Admin Management
        |--------------------------------------------------------------------------
        */
        Route::middleware([
            'superadmin'
        ])->group(function () {

            Route::prefix('admin-management')
                ->name('admin-management.')
                ->group(function () {

                    Route::get(
                        '/',
                        [
                            AdminManagementWebController::class,
                            'index'
                        ]
                    )->name('index');

                    Route::get(
                        '/create',
                        [
                            AdminManagementWebController::class,
                            'create'
                        ]
                    )->name('create');

                    Route::post(
                        '/store',
                        [
                            AdminManagementWebController::class,
                            'store'
                        ]
                    )->name('store');

                    Route::get(
                        '/{id}',
                        [
                            AdminManagementWebController::class,
                            'show'
                        ]
                    )->name('show');

                    Route::post(
                        '/{user}/toggle-status',
                        [
                            AdminManagementWebController::class,
                            'toggleStatus'
                        ]
                    )->name('toggle-status');

                    Route::post(
                        '/{id}/fire',
                        [
                            AdminManagementWebController::class,
                            'fire'
                        ]
                    )->name('fire');
                });


        });

        /*
        |--------------------------------------------------------------------------
        | Logout
        |--------------------------------------------------------------------------
        |
        */
        Route::post(
            '/logout',
            [
                WebAuthController::class,
                'logout'
            ]
        );

    });