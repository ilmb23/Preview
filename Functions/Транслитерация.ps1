function global:TranslitToLAT {
    param([string]$inString)
    $Translit_To_LAT = @{
        [char]'а' = "a"
        [char]'А' = "a"
        [char]'б' = "b"
        [char]'Б' = "b"
        [char]'в' = "v"
        [char]'В' = "v"
        [char]'г' = "g"
        [char]'Г' = "g"
        [char]'д' = "d"
        [char]'Д' = "d"
        [char]'е' = "e"
        [char]'Е' = "e"
        [char]'ё' = "e"
        [char]'Ё' = "e"
        [char]'ж' = "zh"
        [char]'Ж' = "zh"
        [char]'з' = "z"
        [char]'З' = "z"
        [char]'и' = "i"
        [char]'И' = "i"
        [char]'й' = "y"
        [char]'Й' = "y"
        [char]'к' = "k"
        [char]'К' = "k"
        [char]'л' = "l"
        [char]'Л' = "l"
        [char]'м' = "m"
        [char]'М' = "m"
        [char]'н' = "n"
        [char]'Н' = "n"
        [char]'о' = "o"
        [char]'О' = "o"
        [char]'п' = "p"
        [char]'П' = "p"
        [char]'р' = "r"
        [char]'Р' = "r"
        [char]'с' = "s"
        [char]'С' = "s"
        [char]'т' = "t"
        [char]'Т' = "t"
        [char]'у' = "u"
        [char]'У' = "u"
        [char]'ф' = "f"
        [char]'Ф' = "f"
        [char]'х' = "kh"
        [char]'Х' = "kh"
        [char]'ц' = "ts"
        [char]'Ц' = "ts"
        [char]'ч' = "ch"
        [char]'Ч' = "ch"
        [char]'ш' = "sh"
        [char]'Ш' = "sh"
        [char]'щ' = "shch"
        [char]'Щ' = "shch"
        [char]'ъ' = ""
        [char]'Ъ' = ""
        [char]'ы' = "y"
        [char]'Ы' = "y"
        [char]'ь' = ""
        [char]'Ь' = ""
        [char]'э' = "e"
        [char]'Э' = "e"
        [char]'ю' = "yu"
        [char]'Ю' = "yu"
        [char]'я' = "ya"
        [char]'Я' = "ya"
        [char]' ' = "_"
    }
    $outChars = ""
    foreach ($c in $inString.ToCharArray()) {
        if ($Null -cne $Translit_To_LAT[$c] )
        { $outChars += $Translit_To_LAT[$c] }
        else { $outChars += $c }
    }
    Write-Output $outChars
}