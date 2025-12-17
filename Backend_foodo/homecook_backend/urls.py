from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from users.views import (
    login_view, signup_view, current_user, update_profile, send_otp, verify_email, resend_otp,
    forgot_password, verify_password_reset_otp, reset_password,
    get_addresses, create_address, update_address, delete_address, set_default_address,
    google_signin
)
from meals.views import MealViewSet, NutritionViewSet
from orders.views import OrderViewSet

router = DefaultRouter()
router.register(r'meals', MealViewSet)
router.register(r'nutrition', NutritionViewSet)
router.register(r'orders', OrderViewSet, basename='order')  

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/login/', login_view, name='login'),
    path('api/auth/signup/', signup_view, name='signup'),
    path('api/auth/google-signin/', google_signin, name='google_signin'),
    path('api/auth/me/', current_user, name='current_user'),
    path('api/auth/profile/', update_profile, name='update_profile'),
    path('api/auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # OTP endpoints
    path('api/auth/send-otp/', send_otp, name='send_otp'),
    path('api/auth/verify-email/', verify_email, name='verify_email'),
    path('api/auth/resend-otp/', resend_otp, name='resend_otp'),
    # Password reset endpoints
    path('api/auth/forgot-password/', forgot_password, name='forgot_password'),
    path('api/auth/verify-password-reset-otp/', verify_password_reset_otp, name='verify_password_reset_otp'),
    path('api/auth/reset-password/', reset_password, name='reset_password'),
    # Address endpoints
    path('api/addresses/', get_addresses, name='get_addresses'),
    path('api/addresses/create/', create_address, name='create_address'),
    path('api/addresses/<int:address_id>/', update_address, name='update_address'),
    path('api/addresses/<int:address_id>/delete/', delete_address, name='delete_address'),
    path('api/addresses/<int:address_id>/set-default/', set_default_address, name='set_default_address'),
    path('api/', include(router.urls)),
]



