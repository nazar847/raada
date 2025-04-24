import subprocess
from collections import defaultdict
from art import text2art

def read_accounts(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        accounts = file.readlines()
    return accounts

def group_accounts_by_server(accounts, item_prices):
    server_data = defaultdict(list)
    server_totals = defaultdict(float)

    for account in accounts:
        parts = account.strip().split(';')
        if len(parts) >= 6:
            server_name = parts[0]
            server_ip_port = parts[1]
            item = parts[5]
            ip, port = server_ip_port.split(':')

            if not ('Impala' in item) and not ('Mitsubishi' in item) and not ('Clover' in item):
                price = 0
                for key, value in item_prices.items():
                    if key in item:  # Проверяем наличие части названия
                        price = int(value)
                        break
                server_data[server_name].append((ip, port, item, price))
                server_totals[server_name] += price

    return server_data, server_totals

def display_servers(servers, server_totals):
    print("\n" + ("-" * 40) + "\n")
    sorted_servers = sorted(servers.items(), key=lambda x: server_totals[x[0]])

    for index, (server_name, accounts) in enumerate(sorted_servers, start=1):
        total_value = int(server_totals[server_name])
        print(f"Сервер {index}: {server_name} (Количество аккаунтов: {len(accounts)}, Общая стоимость предметов: {total_value} KK)")
        for ip, port, item, price in accounts:
            print(f"  - {item} (Цена: {price} KK)")
        print("\n" + ("-" * 40) + "\n")

    total_all_servers = sum(server_totals.values())
    print(f"Общая стоимость всех предметов на всех серверах: {int(total_all_servers)} KK\n")

    return sorted_servers

def main():
    print(text2art("LoveKa"))
    print(text2art("PeReKiD"))

    # Задаём цены для предметов
    item_prices = {
        "Тактический бронежилет": 0,
        "Тактический шлем": 200,
        "Маска череп": 200,
        "Скин: Катсу (ID: 862)": 0,
        "Скин: Ися (ID: 861)": 0,
        "Скин: Хиток (ID: 869)": 0,
        "Анимированная пчела": 0,
        "Оружие Бамбли Би": 200,
        "Паучьи лапы": 50,
        "Складная мусорная лавка": 150,
        "Воздушный шар Бомж": 150,
        "Скин: Sam Mason Военный (ID: 863)": 0,
        "Скин: Гоуст (ID: 860)": 70,
        "Скин: Коннор Военный (ID: 865)": 0,
        "Осколок читерского Clover": 0,
        "Опыт депозита": 200,
    }

    accounts = read_accounts('accounts.txt')

    server_data, server_totals = group_accounts_by_server(accounts, item_prices)

    sorted_servers = display_servers(server_data, server_totals)

    while True:
        choice = input("Введите номер сервера для запуска или часть названия сервера: ")
        try:
            choice_index = int(choice) - 1
            if 0 <= choice_index < len(sorted_servers):
                server_name, accounts = sorted_servers[choice_index]
                ip, port, _, _ = accounts[0]
                print(f"\nЗапускаем сервер {server_name} с IP: {ip} и Port: {port}...")
                subprocess.Popen([r"raksamp lite.exe", "-h", ip, "-p", str(port), "-n", 'nick', "-z"])
                break
            else:
                print("Неверный номер сервера.")
        except ValueError:
            # Если введена часть названия сервера
            matching_servers = [s for s in server_data if choice.lower() in s.lower()]
            if matching_servers:
                for server_name in matching_servers:
                    index = next(i for i, (s, _) in enumerate(sorted_servers) if s == server_name) + 1
                    print(f"\nСервер {index}: {server_name}")
                    for ip, port, item, _ in server_data[server_name]:
                        print(f"  - {item}")
                print("\nНажмите Enter для продолжения...")
                input()
                main()  # Перезапуск программы
                return
            else:
                print("Сервер с таким названием не найден.")

if __name__ == "__main__":
    main()