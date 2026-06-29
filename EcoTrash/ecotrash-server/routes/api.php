<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProfileController;

use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ReviewController;

use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\WithdrawalController;

use App\Http\Controllers\Api\NotificationController;

use App\Http\Controllers\Api\WasteCategoryController;
use App\Http\Controllers\Api\SellerAddressController;

use App\Http\Controllers\Api\CourierLocationController;

use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\AdminOrderController;
use App\Http\Controllers\Api\AdminCourierController;

use App\Http\Controllers\Api\SuperAdminController;

/*
|--------------------------------------------------------------------------
| PUBLIC ROUTES
|--------------------------------------------------------------------------
*/

Route::post(
    '/register',
    [AuthController::class, 'register']
);

Route::post(
    '/login',
    [AuthController::class, 'login']
);

Route::get(
    '/storage-proxy/{path}',
    function ($path) {
        $path = storage_path('app/public/' . $path);
        if (!file_exists($path)) {
            abort(404);
        }
        $file = file_get_contents($path);
        $type = mime_content_type($path);
        return response($file, 200)->header('Content-Type', $type);
    }
)->where('path', '.*');

/*
|--------------------------------------------------------------------------
| AUTHENTICATED ROUTES
|--------------------------------------------------------------------------
*/

Route::middleware([
    'auth:sanctum'
])->group(function () {

    Route::post(
        '/logout',
        [AuthController::class, 'logout']
    );
    /*
    |--------------------------------------------------------------------------
    | PROFILE
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/profile',
        [ProfileController::class, 'show']
    );

    Route::patch(
        '/profile',
        [ProfileController::class, 'update']
    );

    Route::post(
        '/profile',
        [ProfileController::class, 'update']
    );

    Route::post(
        '/profile',
        [ProfileController::class, 'update']
    );

    Route::patch(
        '/profile/password',
        [ProfileController::class, 'changePassword']
    );

    /*
    |--------------------------------------------------------------------------
    | WASTE CATEGORY
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/waste-categories',
        [WasteCategoryController::class, 'index']
    );

    Route::get(
        '/waste-categories/{id}',
        [WasteCategoryController::class, 'show']
    );

    /*
    |--------------------------------------------------------------------------
    | WALLET
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/wallet',
        [WalletController::class, 'myWallet']
    );

    Route::get(
        '/wallet/summary',
        [WalletController::class, 'summary']
    );

    Route::get(
        '/wallet/transactions',
        [WalletController::class, 'transactions']
    );

    /*
    |--------------------------------------------------------------------------
    | NOTIFICATIONS
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/notifications',
        [NotificationController::class, 'index']
    );

    Route::patch(
        '/notifications/{id}/read',
        [NotificationController::class, 'markAsRead']
    );

    Route::patch(
        '/notifications/read-all',
        [NotificationController::class, 'markAllAsRead']
    );

    Route::get(
        '/notifications/unread-count',
        [NotificationController::class, 'unreadCount']
    );

    /*
    |--------------------------------------------------------------------------
    | MAP
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/orders/{id}/map',
        [OrderController::class, 'map']
    );

    Route::get(
        '/orders',
        [OrderController::class, 'index']
    );

    Route::get(
        '/orders/{id}',
        [OrderController::class, 'show']
    );
});

/*
|--------------------------------------------------------------------------
| SELLER ROUTES
|--------------------------------------------------------------------------
*/

Route::middleware([
    'auth:sanctum',
    'role:3'
])->group(function () {

    /*
    |--------------------------------------------------------------------------
    | SELLER ADDRESS
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/seller-addresses',
        [SellerAddressController::class, 'index']
    );

    Route::get(
        '/seller-addresses/{id}',
        [SellerAddressController::class, 'show']
    );

    Route::post(
        '/seller-addresses',
        [SellerAddressController::class, 'store']
    );

    Route::put(
        '/seller-addresses/{id}',
        [SellerAddressController::class, 'update']
    );

    Route::delete(
        '/seller-addresses/{id}',
        [SellerAddressController::class, 'destroy']
    );

    /*
    |--------------------------------------------------------------------------
    | ORDERS
    |--------------------------------------------------------------------------
    */

    Route::post(
        '/orders',
        [OrderController::class, 'store']
    );

    Route::patch(
        '/orders/{id}/cancel',
        [OrderController::class, 'cancel']
    );

    /*
    |--------------------------------------------------------------------------
    | REVIEWS
    |--------------------------------------------------------------------------
    */

    Route::post(
        '/reviews',
        [ReviewController::class, 'store']
    );

    /*
    |--------------------------------------------------------------------------
    | WITHDRAWALS
    |--------------------------------------------------------------------------
    */

    Route::get(
        '/withdrawals',
        [WithdrawalController::class, 'index']
    );

    Route::post(
        '/withdrawals',
        [WithdrawalController::class, 'store']
    );
});

    /*
    |--------------------------------------------------------------------------
    | COURIER ROUTES
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'auth:sanctum',
        'role:4'
    ])->group(function () {

        /*
        |--------------------------------------------------------------------------
        | AVAILABLE ORDERS
        |--------------------------------------------------------------------------
        */

        Route::get(
            '/courier/orders/available',
            [OrderController::class, 'availableOrders']
        );

        /*
        |--------------------------------------------------------------------------
        | ORDER OPERATION
        |--------------------------------------------------------------------------
        */

        Route::patch(
            '/orders/{id}/accept',
            [OrderController::class, 'accept']
        );

        Route::post(
            '/orders/{id}/pickup',
            [OrderController::class, 'pickup']
        );

        Route::patch(
            '/orders/{id}/deliver',
            [OrderController::class, 'deliver']
        );

        Route::patch(
            '/orders/{id}/complete',
            [OrderController::class, 'complete']
        );

        /*
        |--------------------------------------------------------------------------
        | REVIEWS
        |--------------------------------------------------------------------------
        */

        Route::get(
            '/reviews/my-received',
            [ReviewController::class, 'myReceivedReviews']
        );

        // legacy route
        Route::get(
            '/courier/reviews',
            [ReviewController::class, 'myReceivedReviews']
        );

        /*
        |--------------------------------------------------------------------------
        | LOCATION
        |--------------------------------------------------------------------------
        */

        Route::patch(
            '/courier/location',
            [CourierLocationController::class, 'update']
        );

        Route::patch(
            '/courier/toggle-online',
            [CourierLocationController::class, 'toggleOnline']
        );
    });

    /*
    |--------------------------------------------------------------------------
    | ADMIN + SUPER ADMIN
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'auth:sanctum',
        'role:1,2'
    ])->group(function () {

        /*
        |--------------------------------------------------------------------------
        | DASHBOARD
        |--------------------------------------------------------------------------
        */

        Route::get(
            '/admin/dashboard',
            [AdminDashboardController::class, 'index']
        );

        Route::get(
            '/admin/dashboard/recent-orders',
            [AdminDashboardController::class, 'recentOrders']
        );

        Route::get(
            '/admin/dashboard/recent-withdrawals',
            [AdminDashboardController::class, 'recentWithdrawals']
        );

        Route::get(
            '/admin/dashboard/top-couriers',
            [AdminDashboardController::class, 'topCouriers']
        );

        Route::get(
            '/admin/dashboard/top-sellers',
            [AdminDashboardController::class, 'topSellers']
        );

        /*
        |--------------------------------------------------------------------------
        | ADMIN ORDERS
        |--------------------------------------------------------------------------
        */

        Route::get(
            '/admin/orders',
            [AdminOrderController::class, 'index']
        );




        /*
        |--------------------------------------------------------------------------
        | COURIER MANAGEMENT
        |--------------------------------------------------------------------------
        */

        Route::get(
            '/admin/couriers',
            [AdminCourierController::class, 'index']
        );

        Route::post(
            '/admin/couriers',
            [AdminCourierController::class, 'store']
        );

        Route::patch(
            '/admin/couriers/{id}/activate',
            [AdminCourierController::class, 'activate']
        );

        Route::patch(
            '/admin/couriers/{id}/deactivate',
            [AdminCourierController::class, 'deactivate']
        );
    });

    /*
    |--------------------------------------------------------------------------
    | SUPER ADMIN ONLY
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'auth:sanctum',
        'role:1'
    ])->group(function () {

        Route::get(
            '/super-admin/admins',
            [SuperAdminController::class, 'index']
        );

        Route::post(
            '/super-admin/admins',
            [SuperAdminController::class, 'store']
        );

        Route::patch(
            '/super-admin/admins/{id}/activate',
            [SuperAdminController::class, 'activate']
        );

        Route::patch(
            '/super-admin/admins/{id}/deactivate',
            [SuperAdminController::class, 'deactivate']
        );

        Route::delete(
            '/super-admin/admins/{id}',
            [SuperAdminController::class, 'fire']
        );
    });

    /*
    |--------------------------------------------------------------------------
    | ADMIN WASTE CATEGORY MANAGEMENT
    |--------------------------------------------------------------------------
    */

    Route::middleware([
        'auth:sanctum',
        'role:1,2'
    ])->group(function () {

        Route::post(
            '/waste-categories',
            [WasteCategoryController::class, 'store']
        );

        Route::put(
            '/waste-categories/{id}',
            [WasteCategoryController::class, 'update']
        );

        Route::delete(
            '/waste-categories/{id}',
            [WasteCategoryController::class, 'destroy']
        );
    });