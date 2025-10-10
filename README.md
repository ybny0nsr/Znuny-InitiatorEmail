# Znuny-InitiatorEmail

Модуль для Znuny 6.2, который при создании тикета из письма:
- проверяет отправителя (например, `testsender@domain.zone`);
- извлекает первую строку вида `Email: sender.name@domain.zone` из тела письма;
- записывает найденный адрес в динамическое поле `InitiatorEmail`.

## Структура решения
1. Perl‑модуль: Kernel/System/PostMaster/Filter/InitiatorEmail.pm
2. SysConfig‑ключи (чтобы не хардкодить):
PostMaster::PreFilterModule###InitiatorEmail::Senders — список адресов отправителей (через запятую).
PostMaster::PreFilterModule###InitiatorEmail::Regex — регулярное выражение для поиска email в теле письма.
PostMaster::PreFilterModule###InitiatorEmail::DynamicField — имя динамического поля, куда писать.

## Установка
1. Соберите пакет `.opm` из `.sopm` файла:
   ```bash
   bin/otrs.Console.pl Dev::Package::Build SOPM/Znuny-InitiatorEmail.sopm
