<#
Преобразование первых букв в заглавные, остальные в строчные
Преобразование английских букв в русские

строчка для теста, содержит строчные, большие и английсике буквы
TranslitToForm "ПетРOв-сиДоров-   ApБем-иБН-ХaТaб АлекСандровиЧ"
вывод:
Петров-Сидоров Арбем-Ибн-Хатаб Александрович
#>
function global:TranslitToForm {
    param([string]$inputstring)
    $HighChars = @{
        [char]'а' = "А"
        [char]'б' = "Б"
        [char]'в' = "В"
        [char]'г' = "Г"
        [char]'д' = "Д"
        [char]'е' = "Е"
        [char]'ё' = "Е"
        [char]'ж' = "Ж"
        [char]'з' = "З"
        [char]'и' = "И"
        [char]'й' = "Й"
        [char]'к' = "К"
        [char]'л' = "Л"
        [char]'м' = "М"
        [char]'н' = "Н"
        [char]'о' = "О"
        [char]'п' = "П"
        [char]'р' = "Р"
        [char]'с' = "С"
        [char]'т' = "Т"
        [char]'у' = "У"
        [char]'ф' = "Ф"
        [char]'х' = "Х"
        [char]'ц' = "Ц"
        [char]'ч' = "Ч"
        [char]'ш' = "Ш"
        [char]'щ' = "Щ"
        [char]'ы' = "Ы"
        [char]'э' = "Э"
        [char]'ю' = "Ю"
        [char]'я' = "Я"
        [char]'А' = "А"
        [char]'Б' = "Б"
        [char]'В' = "В"
        [char]'Г' = "Г"
        [char]'Д' = "Д"
        [char]'Е' = "Е"
        [char]'Ё' = "Е"
        [char]'Ж' = "Ж"
        [char]'З' = "З"
        [char]'И' = "И"
        [char]'Й' = "Й"
        [char]'К' = "К"
        [char]'Л' = "Л"
        [char]'М' = "М"
        [char]'Н' = "Н"
        [char]'О' = "О"
        [char]'П' = "П"
        [char]'Р' = "Р"
        [char]'С' = "С"
        [char]'Т' = "Т"
        [char]'У' = "У"
        [char]'Ф' = "Ф"
        [char]'Х' = "Х"
        [char]'Ц' = "Ц"
        [char]'Ч' = "Ч"
        [char]'Ш' = "Ш"
        [char]'Щ' = "Щ"
        [char]'Ы' = "Ы"
        [char]'Э' = "Э"
        [char]'Ю' = "Ю"
        [char]'Я' = "Я"
        #не русские буквы в русские буквы
        [char]'E' = "Е"
        [char]'T' = "Т"
        [char]'O' = "О"
        [char]'P' = "Р"
        [char]'A' = "А"
        [char]'H' = "Н"
        [char]'K' = "К"
        [char]'X' = "Х"
        [char]'C' = "С"
        [char]'B' = "В"
        [char]'M' = "М"
        [char]'e' = "Е"
        [char]'y' = "У"
        [char]'o' = "О"
        [char]'p' = "Р"
        [char]'a' = "А"
        [char]'k' = "К"
        [char]'x' = "Х"
        [char]'c' = "С"
        [char]'n' = "П"
    }
    $LowChars = @{
        [char]'а' = "а"
        [char]'б' = "б"
        [char]'в' = "в"
        [char]'г' = "г"
        [char]'д' = "д"
        [char]'е' = "е"
        [char]'ё' = "е"
        [char]'ж' = "ж"
        [char]'з' = "з"
        [char]'и' = "и"
        [char]'й' = "й"
        [char]'к' = "к"
        [char]'л' = "л"
        [char]'м' = "м"
        [char]'н' = "н"
        [char]'о' = "о"
        [char]'п' = "п"
        [char]'р' = "р"
        [char]'с' = "с"
        [char]'т' = "т"
        [char]'у' = "у"
        [char]'ф' = "ф"
        [char]'х' = "х"
        [char]'ц' = "ц"
        [char]'ч' = "ч"
        [char]'ш' = "ш"
        [char]'щ' = "щ"
        [char]'ы' = "ы"
        [char]'э' = "э"
        [char]'ю' = "ю"
        [char]'я' = "я"
        [char]'ь' = "ь"
        [char]'ъ' = "ъ"
        [char]'А' = "а"
        [char]'Б' = "б"
        [char]'В' = "в"
        [char]'Г' = "г"
        [char]'Д' = "д"
        [char]'Е' = "е"
        [char]'Ё' = "е"
        [char]'Ж' = "ж"
        [char]'З' = "з"
        [char]'И' = "и"
        [char]'Й' = "й"
        [char]'К' = "к"
        [char]'Л' = "л"
        [char]'М' = "м"
        [char]'Н' = "н"
        [char]'О' = "о"
        [char]'П' = "п"
        [char]'Р' = "р"
        [char]'С' = "с"
        [char]'Т' = "т"
        [char]'У' = "у"
        [char]'Ф' = "ф"
        [char]'Х' = "х"
        [char]'Ц' = "ц"
        [char]'Ч' = "ч"
        [char]'Ш' = "ш"
        [char]'Щ' = "щ"
        [char]'Ы' = "ы"
        [char]'Э' = "э"
        [char]'Ю' = "ю"
        [char]'Я' = "я"
        [char]'Ь' = "ь"
        [char]'Ъ' = "ъ"
        #не русские буквы в русские
        [char]'E' = "е"
        [char]'T' = "т"
        [char]'O' = "о"
        [char]'P' = "р"
        [char]'A' = "а"
        [char]'H' = "н"
        [char]'K' = "к"
        [char]'X' = "х"
        [char]'C' = "с"
        [char]'B' = "в"
        [char]'M' = "м"
        [char]'e' = "е"
        [char]'y' = "у"
        [char]'o' = "о"
        [char]'p' = "р"
        [char]'a' = "а"
        [char]'k' = "к"
        [char]'x' = "х"
        [char]'c' = "с"
        [char]'n' = "п"
    }
    $words = $inputstring.Split(" ") | Where-Object { $_ }
    $r = $null
    foreach ($word in $words) {
        if ($word -like "*-*") {
            $words2 = $word.Split("-") | Where-Object { $_ }
            [int]$c = 0
            while ($c -ne $words2.count) {
                [string]$word3 = $HighChars.$($($words2[$c])[0])
                [int]$c2 = 1
                while ($c2 -ne $($words2[$c]).ToCharArray().count) {
                    $word3 += $LowChars.$($($words2[$c])[$c2])
                    $c2++
                }
                if ($c -lt ($words2.count - 1)) {
                    $word3 += "-"
                    $r += $word3
                }
                else {
                    $word3 += " "
                    $r += $word3
                }
                $c++
            }
        }
        else {
            [string]$word2 = $HighChars.($word[0])
            [int]$c = 1
            while ($c -ne $word.ToCharArray().count) {
                $word2 += $LowChars.($word[$c])
                $c++
                if ($c -eq ($word.ToCharArray().count)) {
                    $word2 += " "
                }
            }
            $r += $word2
        }
    }
    $r = $r.trim()
    Write-Output $r
}