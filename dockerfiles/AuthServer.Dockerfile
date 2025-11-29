# Build image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore services/admin/src/Bamboo.Admin.AuthServer/Bamboo.Admin.AuthServer.csproj
RUN dotnet publish services/admin/src/Bamboo.Admin.AuthServer/Bamboo.Admin.AuthServer.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Bamboo.Admin.AuthServer.dll"]
