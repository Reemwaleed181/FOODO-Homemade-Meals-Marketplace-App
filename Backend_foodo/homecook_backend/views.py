# الموقع: D:\Backend_foodo\homecook_backend\views.py

from rest_framework import viewsets
from homecook_backend.models import Order  # استيراد من models.py
from homecook_backend.serializers import OrderSerializer  # استيراد من serializers.py

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()  # هذا السطر مهم
    serializer_class = OrderSerializer