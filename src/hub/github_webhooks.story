when github events webhooks as webhook
    if webhook.event == 'push'
        # https://developer.github.com/v3/activity/events/types/#pushevent
        service = psql exec query: "SELECT services.uuid FROM app_public.services INNER JOIN app_hidden.repos ON repos.uuid = services.repo_uuid WHERE repos.service_id = cast({webhook.payload['repository']['id']} as text) LIMIT 1;"
        if service
            yml = github contents path:'microservice.yml' ref:'master'
            output = yaml parse data:yml.content
            # TODO omg parse the output
            psql update table: 'service_tags'
                        where: {'service_id': service['service_id'], 'tag': 'latest'}
                        set: {'configuration': output}
