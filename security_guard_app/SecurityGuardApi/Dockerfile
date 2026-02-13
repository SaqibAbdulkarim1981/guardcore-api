FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["SecurityGuardApi.csproj", "./"]
RUN dotnet restore "./SecurityGuardApi.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src"
RUN dotnet build "SecurityGuardApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SecurityGuardApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create directory for database (PostgreSQL will use connection string from env)
RUN mkdir -p /app/data

ENTRYPOINT ["dotnet", "SecurityGuardApi.dll"]
