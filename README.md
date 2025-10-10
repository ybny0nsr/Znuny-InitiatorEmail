## Znuny-InitiatorEmail

Модуль для Znuny 6.2, который при создании тикета из письма:
- проверяет отправителя (например, `testsender@domain.zone`);
- извлекает первую строку вида `Email: sender.name@domain.zone` из тела письма;
- записывает найденный адрес в динамическое поле `InitiatorEmail`.

### Структура решения
1. Perl‑модуль: Kernel/System/PostMaster/Filter/InitiatorEmail.pm
2. Определяем SysConfig‑ключи в файле .sopm (хранится в репозитории модуля в папке SOPM/):
- PostMaster::PreFilterModule###InitiatorEmail::Senders — список адресов отправителей (через запятую).
- PostMaster::PreFilterModule###InitiatorEmail::Regex — регулярное выражение для поиска email в теле письма.
- PostMaster::PreFilterModule###InitiatorEmail::DynamicField — имя динамического поля, куда писать.
*При сборке пакета через Package Manager Znuny читает .sopm и добавляет в SysConfig новые ключи. 
Эти ключи появляются в админке (Администрирование → Системная конфигурация), так что администратор может менять их значения прямо из Znuny без правки кода.*

### Настройки в SysConfig
В SysConfig → PostMaster::PreFilterModule добавляем:
- PostMaster::PreFilterModule###InitiatorEmail = Kernel::System::PostMaster::Filter::InitiatorEmail
- PostMaster::PreFilterModule###InitiatorEmail::Senders = testsender@domain.zone
- PostMaster::PreFilterModule###InitiatorEmail::Regex = ^Email:\s*([A-Za-z0-9._%+-]+\@[A-Za-z0-9.-]+\.[A-Za-z]{2,})
- PostMaster::PreFilterModule###InitiatorEmail::DynamicField = InitiatorEmail

### Установка
1. Соберите пакет `.opm` из `.sopm` файла:
   ```bash
   bin/otrs.Console.pl Dev::Package::Build SOPM/Znuny-InitiatorEmail.sopm
2. Установите пакет через Znuny Package Manager.
3. Настройте SysConfig:
- PostMaster::PreFilterModule###InitiatorEmail → Kernel::System::PostMaster::Filter::InitiatorEmail
- PostMaster::PreFilterModule###InitiatorEmail::Senders → список адресов (через запятую)
- PostMaster::PreFilterModule###InitiatorEmail::Regex → регулярное выражение для поиска email
- PostMaster::PreFilterModule###InitiatorEmail::DynamicField → имя динамического поля (например - InitiatorEmail)

### Конфигурация
- Динамическое поле: создайте поле InitiatorEmail типа Text в разделе Ticket.
- SysConfig: укажите список отправителей и регулярное выражение для извлечения email.
- Regex по умолчанию: ^Email:\s*([A-Za-z0-9._%+-]+\@[A-Za-z0-9.-]+\.[A-Za-z]{2,})

### CI/CD
В репозитории настроен GitHub Actions workflow .github/workflows/build.yml, который выполняет:
- Проверку синтаксиса Perl (perl -c для всех .pm файлов).
- Сборку .opm пакета внутри контейнера znuny/znuny:6.2
- все .sopm в каталоге SOPM/ проверяются на корректность XML. Если XML битый — job упадёт сразу.
*Таким образом, каждый пуш в ветку main автоматически проверяется и таким образом повышается вероятность, что пакет можно собрать, установить и удалить без ошибок.*
