CREATE OR REPLACE PROCEDURE export_genres_to_json IS
    l_json_str VARCHAR2(4000); -- Строка для формирования JSON
    l_file UTL_FILE.FILE_TYPE;
    l_directory CONSTANT VARCHAR2(100) := 'JSON_DIR'; -- Каталог для хранения JSON
    is_first_record BOOLEAN := TRUE; -- Флаг для первой записи
BEGIN
    -- Открываем файл для записи
    l_file := UTL_FILE.FOPEN(l_directory, 'genres.json', 'w', 32767);

    -- Записываем открывающую скобку массива JSON
    UTL_FILE.PUT_LINE(l_file, '[');

    -- Цикл по строкам из таблицы жанров
    FOR rec IN (SELECT genre_id, genre_name FROM genres) LOOP
        -- Если не первая запись, добавляем запятую перед новой записью
        IF NOT is_first_record THEN
            UTL_FILE.PUT_LINE(l_file, ',');
        ELSE
            is_first_record := FALSE; -- Сбрасываем флаг после первой записи
        END IF;

        -- Формируем JSON-строку для текущей записи
        l_json_str := '{"genre_id":' || rec.genre_id || ',"genre_name":"' || rec.genre_name || '"}';

        -- Записываем строку JSON в файл
        UTL_FILE.PUT_LINE(l_file, l_json_str);
    END LOOP;

    -- Закрываем массив JSON и файл
    UTL_FILE.PUT_LINE(l_file, ']');
    UTL_FILE.FCLOSE(l_file);

    DBMS_OUTPUT.PUT_LINE('Данные успешно экспортированы в файл genres.json');
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(l_file) THEN
            UTL_FILE.FCLOSE(l_file);
        END IF;
        RAISE;
END;
/


-- Импорт данных из JSON в таблицу genres
CREATE OR REPLACE PROCEDURE import_genres_from_json IS
    l_file UTL_FILE.FILE_TYPE;
    l_json_str VARCHAR2(4000);
    l_genre_id NUMBER;
    l_genre_name VARCHAR2(50);
    l_directory CONSTANT VARCHAR2(100) := 'JSON_DIR'; -- Имя каталога
BEGIN
    -- Открываем файл для чтения
    l_file := UTL_FILE.FOPEN(l_directory, 'genres.json', 'r');

    -- Читаем открывающую скобку массива JSON (не обрабатываем её)
    UTL_FILE.GET_LINE(l_file, l_json_str); -- Пропускаем строку с [

    -- Читаем остальные строки до закрывающей скобки
    LOOP
        BEGIN
            -- Читаем строку из файла (каждая строка JSON)
            UTL_FILE.GET_LINE(l_file, l_json_str);

            -- Прерываем цикл, если строка закрывающей скобки ]
            IF l_json_str = ']' THEN
                EXIT;
            END IF;

            -- Парсим JSON строку и извлекаем значения
            -- Формат JSON: {"genre_id":1, "genre_name":"Rock"}
            l_genre_id := TO_NUMBER(REGEXP_SUBSTR(l_json_str, '"genre_id":([0-9]+)', 1, 1, NULL, 1));
            l_genre_name := REGEXP_SUBSTR(l_json_str, '"genre_name":"([^"]+)"', 1, 1, NULL, 1);
            
            -- Вставляем данные в таблицу
            INSERT INTO genres (genre_id, genre_name)
            VALUES (l_genre_id, l_genre_name);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT; -- Заканчиваем, если нет данных
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Ошибка при импорте строки: ' || l_json_str);
        END;
    END LOOP;

    -- Закрываем файл
    UTL_FILE.FCLOSE(l_file);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Данные успешно импортированы из файла genres.json');
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(l_file) THEN
            UTL_FILE.FCLOSE(l_file);
        END IF;
        RAISE;
END;
/

BEGIN
    export_genres_to_json;
END;
/
BEGIN
    import_genres_from_json;
END;
/
