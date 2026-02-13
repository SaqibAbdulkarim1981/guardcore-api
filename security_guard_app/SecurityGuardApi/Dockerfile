FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["SecurityGuardApi.csproj", "."]
RUN dotnet restore "SecurityGuardApi.csproj"
COPY . .
RUN dotnet build "SecurityGuardApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SecurityGuardApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create directory for SQLite database with proper permissions
RUN mkdir -p /app/data
ENV ConnectionStrings__DefaultConnection="Data Source=/app/data/securityguard.db"

ENTRYPOINT ["dotnet", "SecurityGuardApi.dll"]
