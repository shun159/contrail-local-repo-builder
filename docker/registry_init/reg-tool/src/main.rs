//use actix::prelude::Stream;
use anyhow::{bail, Result};
use bollard::auth::DockerCredentials;
use bollard::errors::Error;
use bollard::image::{CreateImageOptions, PushImageOptions, TagImageOptions};
use bollard::models::{CreateImageInfo, PushImageInfo};
use bollard::{Docker, API_DEFAULT_VERSION};
use futures_util::stream::TryStreamExt;
use std::fs::File;
use std::io::prelude::*;
use structopt::StructOpt;

static CONN_TIMEOUT: u64 = 300;

#[derive(Debug, StructOpt, Clone, Default)]
struct CommandOptions {
    #[structopt(long)]
    username: String,
    #[structopt(long)]
    password: String,
    #[structopt(long, default_value = "localhost:2375")]
    registry: String,
    #[structopt(long, default_value = "localhost:2375")]
    registry_name: String,
    #[structopt(short, long, default_value = "example/sample.txt")]
    targets: String,
}

#[derive(Clone, Debug)]
pub struct Item {
    pub name: String,
    pub tag: String,
}

#[tokio::main]
async fn main() {
    let docker = init_server_conn().unwrap();
    let targets = load_target().unwrap();
    let targets_len = targets.len();
    let mut tmp_len = 1usize;
    for target in targets.iter() {
        println!(
            "Downloading({}/{})..... {}:{}",
            tmp_len, targets_len, target.name, target.tag
        );
        let _res = pull_image(target, &docker).await;
        println!(
            "Tagging({}/{})..... {}:{}",
            tmp_len, targets_len, target.name, target.tag
        );
        let _res = tag_image(target, &docker).await;
        println!(
            "Uploading({}/{})..... {}:{}",
            tmp_len, targets_len, target.name, target.tag
        );
        let _res = push_image(target, &docker).await;
        println!("Complete!");
        tmp_len += 1;
    }
}

// private functions

async fn pull_image(
    target: &Item,
    docker: &Docker,
) -> Result<(), Box<dyn std::error::Error + 'static>> {
    let options = CommandOptions::from_args();
    let image_opts = CreateImageOptions {
        from_image: target.name.clone(),
        tag: target.tag.clone(),
        ..Default::default()
    };
    let cred_opts = if target.name.contains("contrail") || target.name.contains("appformix") {
        Some(DockerCredentials {
            username: Some(options.username),
            password: Some(options.password),
            ..Default::default()
        })
    } else {
        None
    };
    let _result: Vec<CreateImageInfo> = docker
        .create_image(Some(image_opts), None, cred_opts)
        .try_collect()
        .await?;
    Ok(())
}

async fn tag_image(
    target: &Item,
    docker: &Docker,
) -> Result<(), Box<dyn std::error::Error + 'static>> {
    let options = CommandOptions::from_args();
    let name = target.name.clone().replace("hub.juniper.net/contrail/", "");
    let repo_name = format!("{}/{}:{}", options.registry_name, name, target.tag);
    let img_name = format!("{}:{}", target.name, target.tag);
    println!("name: {}, image: {}", repo_name, img_name);
    let tag_opt = TagImageOptions {
        tag: target.tag.clone(),
        repo: repo_name,
    };
    let _result = docker.tag_image(&img_name, Some(tag_opt)).await?;
    Ok(())
}

async fn push_image(
    target: &Item,
    docker: &Docker,
) -> Result<(), Box<dyn std::error::Error + 'static>> {
    let options = CommandOptions::from_args();
    let name = target.name.clone().replace("hub.juniper.net/contrail/", "");
    let img_name = format!("{}/{}:{}", options.registry_name, name, target.tag);
    let push_opts = PushImageOptions {
        tag: target.tag.clone(),
        ..Default::default()
    };
    let _result: Vec<PushImageInfo> = docker
        .push_image(&img_name, Some(push_opts), None)
        .try_collect()
        .await?;
    Ok(())
}

fn load_target() -> Result<Vec<Item>> {
    let options = CommandOptions::from_args();
    match read_file(&options) {
        Ok(items) => Ok(items),
        Err(_) => bail!("Failed to load file: {}", options.targets),
    }
}

fn init_server_conn() -> Result<Docker, Error> {
    let options = CommandOptions::from_args();
    let server = options.registry.clone();
    let docker = Docker::connect_with_http(&server, CONN_TIMEOUT, API_DEFAULT_VERSION)?;
    Ok(docker)
}

fn read_file(options: &CommandOptions) -> std::io::Result<Vec<Item>> {
    let file = File::open(options.targets.clone())?;
    let reader = std::io::BufReader::new(file);
    let mut targets = Vec::new();
    for line in reader.lines() {
        if let Ok(target) = line {
            let mut tmp = target.split(":");
            if let (Some(name), Some(tag)) = (tmp.next(), tmp.next()) {
                targets.push(Item {
                    name: name.to_string(),
                    tag: tag.to_string(),
                })
            }
        }
    }
    Ok(targets)
}
