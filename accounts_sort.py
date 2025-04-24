def sort_accounts_by_items(file_path):
    # Чтение файла
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Фильтрация пустых строк
    lines = [line.strip() for line in lines if line.strip()]
    
    # Создание словаря, где ключ - предмет, значение - список строк с этим предметом
    items_dict = {}
    
    for line in lines:
        parts = line.split(';')
        if len(parts) >= 6:  # Проверка, что строка содержит все необходимые части
            item = parts[5]  # Предмет находится в шестой части (индекс 5)
            if item not in items_dict:
                items_dict[item] = []
            items_dict[item].append(line)
    
    # Приоритетные предметы в нужном порядке
    priority_items = [
        "Оружие Бамбли Би", 
        "Тактический шлем", 
        "Маска череп", 
        "Складная мусорная лавка", 
        "Паучьи лапы", 
        "Воздушный шар Бомж", 
        "Скин: Гоуст (ID: 860)"
    ]
    
    # Получаем все предметы, которые не в приоритетном списке
    other_items = sorted([item for item in items_dict.keys() if item not in priority_items])
    
    # Функция для сортировки строк по серверу
    def sort_by_server(lines):
        return sorted(lines, key=lambda x: x.split(';')[0])
    
    # Запись отсортированных данных в тот же файл
    with open(file_path, 'w', encoding='utf-8') as f:
        # Сначала записываем приоритетные предметы в указанном порядке
        for item in priority_items:
            if item in items_dict:
                sorted_lines = sort_by_server(items_dict[item])
                for line in sorted_lines:
                    f.write(line + '\n')
                f.write('\n')  # Пустая строка между группами
        
        # Затем записываем остальные предметы в алфавитном порядке
        for item in other_items:
            sorted_lines = sort_by_server(items_dict[item])
            for line in sorted_lines:
                f.write(line + '\n')
            f.write('\n')  # Пустая строка между группами

# Использование функции
file_path = "accounts.txt"  # Путь к вашему файлу

sort_accounts_by_items(file_path)
print(f"Файл успешно отсортирован и сохранен обратно в {file_path}")
