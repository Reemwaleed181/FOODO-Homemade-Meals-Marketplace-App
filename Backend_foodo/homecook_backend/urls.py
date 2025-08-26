from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from users.views import login_view, signup_view, current_user, send_otp, verify_email, resend_otp, forgot_password, verify_password_reset_otp, reset_password
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
    path('api/auth/me/', current_user, name='current_user'),
    path('api/auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    # OTP endpoints
    path('api/send-otp/', send_otp, name='send_otp'),
    path('api/verify-email/', verify_email, name='verify_email'),
    path('api/resend-otp/', resend_otp, name='resend_otp'),
    # Password reset endpoints
    path('api/forgot-password/', forgot_password, name='forgot_password'),
    path('api/verify-password-reset-otp/', verify_password_reset_otp, name='verify_password_reset_otp'),
    path('api/reset-password/', reset_password, name='reset_password'),
    path('api/', include(router.urls)),
]



