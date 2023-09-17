require 'json'
require 'aws-sdk-ecs'

def lambda_handler(event:, context:)
  ecs_client = Aws::ECS::Client.new(region: 'ap-northeast-1')

  task_def = 'dbmanager_scraper'
  cluster = 'arn:aws:ecs:ap-northeast-1:271172069079:cluster/tapfindcase_cluster'
  subnet = 'subnet-0b254b91641a755b1'
  security_group = 'sg-03409c5b480e9eb89'
  
  # 特定のタスク定義の実行中のタスクを取得
  resp = ecs_client.list_tasks({
    cluster: cluster,
    family: task_def
  })

  # タスクが実行中でない場合のみ新たにタスクを起動
  if resp.task_arns.empty?
    resp = ecs_client.run_task({
      cluster: cluster,
      launch_type: 'FARGATE',
      task_definition: task_def,
      count: 1,
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
