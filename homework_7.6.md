### ДЗ 7.6

1.1\
Ресурсы:\
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L736 \
Датасорсы:\
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L344

1.2\
Параметр "name" конфликтует с "name_prefix": https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L88 \
Ограничение на длину - от 1 до 80 символов\
Регекс - `^([a-zA-Z0-9_-]{1,80}|[a-zA-Z0-9_-]{1,75}\.fifo)$`

Функция создания ресурса aws_sqs_queue:\
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L1673 \
"aws_sqs_queue":        sqs.ResourceQueue()\
Расположение модуля с функцией:\
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L146

При создании с resourceQueueCreate из имени формируется переменная "name" и структура sqs.CreateQueueInput с ее использованием. Более "name" в resourceQueueCreate не упоминается:
```
var name string
	fifoQueue := d.Get("fifo_queue").(bool)
	if fifoQueue {
		name = create.NameWithSuffix(d.Get("name").(string), d.Get("name_prefix").(string), FIFOQueueNameSuffix)
	} else {
		name = create.Name(d.Get("name").(string), d.Get("name_prefix").(string))
	}

	input := &sqs.CreateQueueInput{
		QueueName: aws.String(name),
	}
```
	
В описании структуры sqs.CreateQueueInput (vendor/github.com/aws/aws-sdk-go/service/sqs/api.go) указаны ограничения на длину и содержимое QueueName, которые не проверяются в функции resourceQueueCreate:
```
  // The name of the new queue. The following limits apply to this name:
	//
	//    * A queue name can have up to 80 characters.
	//
	//    * Valid values: alphanumeric characters, hyphens (-), and underscores
	//    (_).
	//
	//    * A FIFO queue name must end with the .fifo suffix.
	//
	// Queue URLs and names are case-sensitive.
	//
	// QueueName is a required field
	QueueName *string `type:"string" required:"true"`
```
	
Однако проверки, соответствующие требованиям к имени, сохранились в функции resourceQueueCustomizeDiff:\
https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L407
