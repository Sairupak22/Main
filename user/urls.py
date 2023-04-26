from django.urls import path, include
from rest_framework.routers import DefaultRouter
from user.views import RegisterAPI


auth_router = DefaultRouter()
auth_router.register("register", RegisterAPI, "registartion")


urlpatterns = [
    path("", include(auth_router.urls), name="Authorisation"),
]
