from rest_framework.response import Response
from rest_framework import viewsets, status
from user.models import User
from user.serializer import UserSerializer


class RegisterAPI(viewsets.ViewSet):
    http_method_names = ["post", "get", "head", "options"]

    def create(self, request, *args, **kwargs):
        try:
            user = User(
                fname=request.data["fname"],
                lname=request.data["lname"],
                email=request.data["email"],
                phone_number=request.data["phone_number"],
            )
            user.save()
            return Response(
                {
                    "status": 201,
                    "message": "User Created. Please Verify your mail",
                    "data": {"id": user.id},
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception:
            return Response(
                {
                    "status": 500,
                    "message": "Something went wrong",
                    "data": {},
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    def list(self, request, *args, **kwargs):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(
            {
                "status": 200,
                "message": "Users list",
                "data": serializer.data,
            },
            status=status.HTTP_200_OK,
        )
