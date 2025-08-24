from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Order, OrderItem
from .serializers import OrderSerializer, OrderItemSerializer
from meals.models import Meal

class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    
    def get_queryset(self):
        user = self.request.user
        if user.is_chef:
            # Chefs can see orders for their meals
            return Order.objects.filter(items__meal__chef=user).distinct()
        else:
            # Customers can see their own orders
            return Order.objects.filter(user=user)
    
    def create(self, request):
        # Extract data from request
        items_data = request.data.get('items', [])
        delivery_notes = request.data.get('delivery_notes', '')
        is_express = request.data.get('express', False)
        
        # Calculate order totals
        subtotal = 0
        order_items = []
        
        for item in items_data:
            meal_id = item.get('mealId')
            quantity = item.get('quantity', 1)
            
            try:
                meal = Meal.objects.get(id=meal_id, is_active=True)
                item_total = meal.price * quantity
                subtotal += item_total
                
                order_items.append({
                    'meal': meal,
                    'quantity': quantity,
                    'unit_price': float(meal.price)
                })
            except Meal.DoesNotExist:
                return Response(
                    {'error': f'Meal with id {meal_id} not found or inactive'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        # Apply delivery fee and tax (from config)
        delivery_fee = 0 if subtotal >= 25 else 3.99
        if is_express:
            delivery_fee = 5.99  # Express delivery fee
        
        tax_rate = 0.08  # From config
        tax = subtotal * tax_rate
        total = subtotal + delivery_fee + tax
        
        # Create order
        order = Order.objects.create(
            user=request.user,
            subtotal=subtotal,
            delivery_fee=delivery_fee,
            tax=tax,
            total=total,
            delivery_notes=delivery_notes,
            is_express=is_express,
            eta="30-45 minutes" if not is_express else "15-25 minutes"
        )
        
        # Create order items
        for item in order_items:
            OrderItem.objects.create(
                order=order,
                meal=item['meal'],
                quantity=item['quantity'],
                unit_price=item['unit_price']
            )
        
        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)