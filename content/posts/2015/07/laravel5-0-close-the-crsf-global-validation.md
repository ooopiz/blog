---
layout: post
title: 'Laravel5.0 關閉CRSF全局驗證'
date: 2015-07-25 08:13
comments: true
categories: 
---
修改Kernel.php
將global middleware的 `'App\Http\Middleware\VerifyCsrfToken'`
移動到route middleware `'csrf' => 'App\Http\Middleware\VerifyCsrfToken'`

```php Kernel.php
class Kernel extends HttpKernel {

    /**
     * The application's global HTTP middleware stack.
     *
     * @var array
     */
    protected $middleware = [
        'Illuminate\Foundation\Http\Middleware\CheckForMaintenanceMode',
        'Illuminate\Cookie\Middleware\EncryptCookies',
        'Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse',
        'Illuminate\Session\Middleware\StartSession',
        'Illuminate\View\Middleware\ShareErrorsFromSession',
    ];
    /**
     * The application's route middleware.
     *
     * @var array
     */
    protected $routeMiddleware = [
        'auth' => 'App\Http\Middleware\Authenticate',
        'auth.basic' => 'Illuminate\Auth\Middleware\AuthenticateWithBasicAuth',
        'guest' => 'App\Http\Middleware\RedirectIfAuthenticated',
        'csrf' => 'App\Http\Middleware\VerifyCsrfToken',
    ];

}
```

此種作法將會取消全局的驗證，如果要加上驗證機制必須在該route的地方
加上 `'middleware' => 'csrf'`
```php routes.php
$router->group(['middleware' => 'csrf'], function($router)
{
  // Protected routes
})
```