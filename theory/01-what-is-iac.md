# 1. What is Infrastructure as Code?

## The problem it solves

Imagine setting up a server the old way. You log into a cloud website, click
"create server," pick a size, click "create database," set up a firewall, click
roughly 40 buttons in total — and write none of it down.

Three months later:
- Something breaks, and nobody remembers what was clicked.
- A teammate needs an identical setup. They click 40 buttons too, and miss 3.
- You want to throw it all away cleanly, but you're not sure what "all" even is.

This "clicking in a console" approach is called **ClickOps**. It doesn't scale,
it isn't repeatable, and it has no history.

## The idea

**Infrastructure as Code (IaC)** means writing your infrastructure down as a
text file, and letting a tool build it for you. Instead of clicking, you write:

> "I want one database table, one function to run my code, and one public web
> address that connects to it."

...in files (the `terraform/*.tf` files in this repo). A tool (Terraform) reads
them and makes it real.

## Why this is a big deal

Because your infrastructure is now just a file in Git, you get everything good
code gives you:

| Benefit | What it means |
|---|---|
| **Repeatable** | Run it again → identical setup, every time. No missed buttons. |
| **Reviewable** | The file is the single source of truth. Read it, know exactly what exists. |
| **Version-controlled** | Git history shows who changed what infrastructure, and when. |
| **Reversible** | One command (`terraform destroy`) tears it all down cleanly. |
| **Shareable** | A teammate clones the repo and builds the same thing. |

## The one-sentence version

> Infrastructure as Code is a **written recipe** for your cloud. ClickOps is
> cooking from memory and hoping; IaC is a recipe anyone can follow to get the
> exact same dish.

Next: [what "serverless" means →](02-what-is-serverless.md)
