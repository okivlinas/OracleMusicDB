-- ������� �������������� ������ ��� ������� SONG_TITLE.
CREATE INDEX SONGS_TITLE_IDX ON SONGS(SONG_TITLE)
INDEXTYPE IS CTXSYS.CONTEXT;


-- ������� ������� ��� ������ ����� �� �������� (SONG_TITLE).
CREATE OR REPLACE FUNCTION SearchSongsByTitle(p_search_term VARCHAR2)
RETURN SYS_REFCURSOR
IS
  RESULT_CURSOR SYS_REFCURSOR;
BEGIN
  BEGIN
    OPEN RESULT_CURSOR FOR
      SELECT *
      FROM SONGS
      WHERE CONTAINS(SONG_TITLE, p_search_term, 1) > 0;

  RETURN RESULT_CURSOR;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('������ ��� ���������� ������: ' || SQLERRM);
      IF RESULT_CURSOR%ISOPEN THEN
        CLOSE RESULT_CURSOR;
      END IF;
      RAISE;
  END;
END SearchSongsByTitle;


-- ������ ������ ������� ��� ������ �� �������� �����.
DECLARE
  search_result SYS_REFCURSOR;
  song_record SONGS%ROWTYPE;
BEGIN
  BEGIN
    -- ���������� ������ �� �������� �����
    search_result := SearchSongsByTitle('Jud%'); 

    DBMS_OUTPUT.PUT_LINE('Song ID | Song Title | Added Date | Song Path');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    
    LOOP
      FETCH search_result INTO song_record;
      EXIT WHEN search_result%NOTFOUND;

      -- �������� ����� ���� �����
      DBMS_OUTPUT.PUT_LINE(song_record.SONG_ID || ' | ' || song_record.SONG_TITLE || ' | ' || song_record.ADDED_DATE || ' | ' || song_record.SONG_PATH);
    END LOOP;

    CLOSE search_result;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('������ ��� ��������� ����������� ������: ' || SQLERRM);
      IF search_result%ISOPEN THEN
        CLOSE search_result;
      END IF;
  END;
END;

