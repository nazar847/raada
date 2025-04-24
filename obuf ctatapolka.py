import re
import base64
import random

def obfuscate_lua_script(file_path):
    with open(file_path, 'r', encoding='windows-1251') as file:
        lua_code = file.read()

    # Удаление комментариев
    lua_code = re.sub(r'--.*', '', lua_code)

    # Удаление лишних пробелов и переносов строк
    lua_code = re.sub(r'\s+', ' ', lua_code)

    # Замена имен переменных (пример)
    lua_code = re.sub(r'\bvar(\d+)\b', lambda match: f'v{int(match.group(1)) + 100}', lua_code)

    # Шифрование строк (пример)
    lua_code = re.sub(r'\"(.*?)\"', lambda match: f'"{match.group(1)[::-1]}"', lua_code)

    # Кодирование всего кода в base64
    encoded_code = base64.b64encode(lua_code.encode('windows-1251')).decode('windows-1251')

    # Однострочная функция декодирования
    decode_function = "function dec(d)local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' d=string.gsub(d,'[^'..b..'=]','')return(d:gsub('.',function(x)if(x=='=')then return''end local r,f='',(b:find(x)-1)for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and'1'or'0')end return r;end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(x)if(#x~=8)then return''end local c=0 for i=1,8 do c=c+(x:sub(i,i)=='1'and 2^(8-i)or 0)end return string.char(c)end))end"

    # Генерация случайных многострочных комментариев
    def generate_random_multiline_comments():
        fake_code = [
            "local x = 10", "function fake() return 42 end", "if x > 5 then x = x - 1 end",
            "for i=1,10 do print(i) end", "while true do break end", "CtataPolka"
        ]
        return '--[[' + '\n'.join(random.choices(fake_code, k=10)) + ']]\n'

    # Создание большого количества строк мусора
    noise = ''.join(generate_random_multiline_comments() for _ in range(1000))

    # Вставка рабочего кода среди мусора
    obfuscated_code = noise + "\n" + decode_function + "\n" + "load(dec('" + encoded_code + "'))()\n" + noise

    # Перезапись файла
    with open(file_path, 'w', encoding='windows-1251') as file:
        file.write(obfuscated_code)

    return obfuscated_code

# Пример использования
obfuscated_code = obfuscate_lua_script('main.lua')
print(obfuscated_code)