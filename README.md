Installation
=========

Add the following lines to config/application.rb in your redmine

```sh
All plugins need to be in the directory /plugins of your redmine

Plugin documents_pops
git clone git@github.com:dotgee/redmine-documents-pops.git

Plugin ckeditor
git clone https://github.com/a-ono/redmine_ckeditor.git 

Plugin invitable
git clone git@github.com:dotgee/redmine-invitable.git

Plugin pops
git clone git@github.com:dotgee/redmine-pops.git

Plugin redmine_http_auth
git clone https://github.com/kevinfoote/redmine_http_auth.git 


Execute tasks after cloning all plugins
rake redmine:pops_project_create_roles
rake redmine:plugins:migrate
```

Insert bdd:
```sh
mysql -u root -p nom_bdd < import_users.sql
mysql -u root -p nom_bdd < import_supports.sql
mysql -u root -p nom_bdd < import_projects.sql
mysql -u root –p nom_bdd < import_projects_members.sql

```

Add to config/application.rb of remdine
```sh
config.paths['app/views'].unshift(PopsRedmineEngine::Engine.root.join('app', 'views'))
config.paths['app/helpers'].unshift(PopsRedmineEngine::Engine.root.join('app', 'helpers').to_s)
config.paths['lib'].unshift(PopsRedmineEngine::Engine.root.join('lib'))
```

License
----

MIT

