# build multi-stage para compilar .NET 10 y dejar una imagen ligera
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# restauro dependencias primero para aprovechar cache
COPY ["koha_agent_mvp.csproj", "./"]
RUN dotnet restore "koha_agent_mvp.csproj"

# compilo todo el proyecto en release
COPY . .
RUN dotnet publish "koha_agent_mvp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# imagen final de runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# libgomp1 para que libllama pueda correr con OpenMP en Linux
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

# puerto donde escucha el servicio
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "koha_agent_mvp.dll"]
