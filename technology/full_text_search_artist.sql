-- Создание полнотекстового индекса для колонки ARTIST_DESCRIPTION
CREATE INDEX ARTIST_DESCRIPTION_IDX ON ARTISTS(ARTIST_DESCRIPTION) 
INDEXTYPE IS CTXSYS.CONTEXT;

-- Создание функции для поиска по описанию артиста
CREATE OR REPLACE FUNCTION SearchArtistsByDescription(p_search_term VARCHAR2)
RETURN SYS_REFCURSOR
IS
  RESULT_CURSOR SYS_REFCURSOR;

BEGIN
  BEGIN
    OPEN RESULT_CURSOR FOR
      SELECT ARTIST_ID, ARTIST_NAME, ARTIST_DESCRIPTION
      FROM ARTISTS
      WHERE CONTAINS(ARTIST_DESCRIPTION, p_search_term, 1) > 0;

    IF RESULT_CURSOR%NOTFOUND THEN
      DBMS_OUTPUT.PUT_LINE('No results found for search term: ' || p_search_term);
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error during search: ' || SQLERRM);
      OPEN RESULT_CURSOR FOR
        SELECT NULL, NULL, NULL FROM DUAL;
  END;

  RETURN RESULT_CURSOR;
END SearchArtistsByDescription;

-- Пример вызова функции
DECLARE
  search_result SYS_REFCURSOR;
  artist_record ARTISTS%ROWTYPE;
BEGIN
  search_result := SearchArtistsByDescription('rock'); 

  DBMS_OUTPUT.PUT_LINE('Artist ID | Artist Name | Artist Description |');
  DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
  
  LOOP
    FETCH search_result INTO artist_record;
    EXIT WHEN search_result%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(artist_record.ARTIST_ID || ' | ' || artist_record.ARTIST_NAME || ' | ' || artist_record.ARTIST_DESCRIPTION || ' | ');
  END LOOP;

  CLOSE search_result;
END;
