from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Meal, Nutrition
from .serializers import MealSerializer, NutritionSerializer
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class MealViewSet(viewsets.ModelViewSet):
    queryset = Meal.objects.filter(is_active=True)
    serializer_class = MealSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_vegetarian', 'is_vegan', 'is_gluten_free']
    search_fields = ['name', 'description', 'chef__username', 'tags']
    ordering_fields = ['price', 'rating', 'order_count', 'created_at']
    ordering = ['-created_at']

    def perform_create(self, serializer):
        serializer.save(chef=self.request.user)

    @action(detail=False, methods=['get'])
    def featured(self, request):
        featured_meals = self.queryset.order_by('-rating')[:10]
        serializer = self.get_serializer(featured_meals, many=True)
        return Response(serializer.data)

class NutritionViewSet(viewsets.ModelViewSet):
    queryset = Nutrition.objects.all()
    serializer_class = NutritionSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]