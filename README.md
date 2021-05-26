# devops-netology

## Поиск в git (ДЗ)

### 1.
hash: aefead2207ef7e2aa5dc81a34aedf0cad4c32545 </br>
comment: Update CHANGELOG.md </br>
 </br>
 git show aefea

### 2.
tag: v0.12.23 </br>
 </br>
git show 85024d3

### 3.
56cd7859e05c36c06b56d013b55a252d0bb7e158, 9ea88f22fc6269854151c571162c5bcf958bee2b </br>
 </br>
git show b8d720^1 --oneline </br>
git show b8d720^2 --oneline </br>
git show b8d720^3 --oneline

### 4.
b14b74c49 [Website] vmc provider links </br>
3f235065b Update CHANGELOG.md </br>
6ae64e247 registry: Fix panic when server is unreachable </br>
5c619ca1b website: Remove links to the getting started guide's old location </br>
06275647e Update CHANGELOG.md </br>
d5f9411f5 command: Fix bug when using terraform login on Windows </br>
4b6d06cc5 Update CHANGELOG.md </br>
dd01a3507 Update CHANGELOG.md </br>
225466bc3 Cleanup after v0.12.23 release </br>
 </br>
git log v0.12.24...v0.12.23 --oneline

### 5.
8c928e83589d90a031f811fae52a81be7153e82f </br>
 </br>
git log -S 'func providerSource' --oneline </br>
git show 5af1e6234 | grep 'func providerSource' </br>
git show 8c928e835 | grep 'func providerSource'

### 6.
8364383c359a6b738a436d1b7745ccdce178df47, 66ebff90cdfaa6938f26f908c7ebad8d547fea17, 41ab0aef7a0fe030e84018973a64135b11abcd70, 52dbf94834cb970b510f2fba853a5b49ad9b1a46, 78b12205587fe839f10d946ea3fdc06719decb05 </br>
 </br>
git grep --heading --break globalPluginDirs </br>
git log -L :globalPluginDirs:plugins.go

### 7.
Martin Atkins 2017-05-03 16:25:41 </br>
 </br>
git grep synchronizedWriters </br>
git log --oneline -S synchronizedWriters </br>
git show 5ac311e2a | grep synchronizedWriters </br>
git show fd4f7eb0b | grep synchronizedWriters </br>
git show bdfea50cc | grep synchronizedWriters </br>
git checkout 5ac311e2a </br>
git blame synchronized_writers.go

## Игнорируемые файлы для Terraform

Все каталоги с именем .terraform. Файлы с именем вида *.tfstate, *.tfstate.*, crash.log, *.tvars, override.tf, override.tf.json, *_override.tf, *_override.tf.json, .terraformrc, terraform.rc в любых каталогах


## Основные стадии разработки нового продукта/функционала

### 1. Определение требований
Менеджер, руководитель проекта и архитектор общаются с клиентом, определяют функционал и требования к продукту.

### 2. Подготовка к разработке
Руководитель проекта определяет этапы разработки.
Архитектор составляет макет продукта, определяет компоненты и их функции, форматы хранения данных, схему взаимодействия между компонентами. Вместе с девопсом определяют конкретные продукты, используемые в качестве компонентов.
Девопс описывает и готовит среду окружения для продукта. Создает проект разработки в средствах CI/CD, раздает доступ разработчикам.

### 3. Разработка
Главный разработчик распределяет задачи по кодированию, разработчики пишут код.
Тестировщики пишут тесты.
Девопс совместно с разработчиками и тестировщиками готовит образы, ресурсы, сервисы, настраивает параметры управляющих сущностей для запуска приложений. Девопс запускает и отключает тестовые среды, управляет доступом, проверяет данные мониторинга, траблешутит проблемы среды.

### 4. Релиз 
При готовности релиза девопс настраивает и запускает продуктовый экземпляр среды и продукта. Подключает их к процессам мониторинга, логирования, резервного копирования.
