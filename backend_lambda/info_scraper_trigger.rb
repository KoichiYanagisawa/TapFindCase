require 'json'
require 'aws-sdk-ecs'
require 'aws-sdk-s3'

def lambda_handler(event:, context:)
  ecs_client = Aws::ECS::Client.new(region: 'ap-northeast-1')
  s3_client = Aws::S3::Client.new(region: 'ap-northeast-1')
  
  bucket_name = 'tapfindcase-scraping-bucket'
  prefix = 'products_detail_urls/'
  objects_count = 0
  s3_client.list_objects_v2(bucket: bucket_name, prefix: prefix).each do |page|
    objects_count += page.contents.length
  end
  required_tasks = (objects_count.to_f / 10).ceil

  task_def = 'info_scraper'
  cluster = 'arn:aws:ecs:ap-northeast-1:271172069079:cluster/tapfindcase_cluster'
  subnet = 'subnet-0b254b91641a755b1'
  security_group = 'sg-03409c5b480e9eb89'
  
  # 特定のタスク定義の実行中のタスクを取得
  resp = ecs_client.list_tasks({
    cluster: cluster,
    family: task_def
  })
  
  # 現在実行中のECSタスクの数を取得
  running_tasks_count = resp.task_arns.length
  # 新たに起動すべきタスクの数を計算
  tasks_to_run = [required_tasks - running_tasks_count, 0].max

  # タスクが実行中でない場合のみ新たにタスクを起動
  if tasks_to_run > 0
    resp = ecs_client.run_task({
      cluster: cluster,
      launch_type: 'FARGATE',
      task_definition: task_def,
      count: tasks_to_run,
      platform_version: 'LATEST',
      network_configuration: {
        awsvpc_configuration: {
          subnets: [subnet],
          security_groups: [security_group],
          assign_public_ip: 'ENABLED',
        }
      }
    })

    # タスク起動結果の確認
    if resp.failures.empty?
      { statusCode: 200, body: JSON.generate('ECS task started.') }
    else
      { statusCode: 500, body: JSON.generate('Failed to start ECS task.') }
    end
  else
    { statusCode: 200, body: JSON.generate('ECS task is already running.') }
  end
end
