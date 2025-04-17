---
date: "[[DATE:YYYY-MM-DDTHH:mm:ss-07:00]]"
categories:
- "Main Blog Post"
draft: false
tags:
  - blogpost
  - how-to
  - Netlify
  - Hugo
  - Obsidian
  - CLI
  - Debian-Linux
  - Scripting
title: "[[Refined Blogging Workflow via Obsidian]]"
---
# Inspiration
So, first and foremost - credit where credit is due. This idea wasn't my own, and although I put my own spin on things, I only knew of the possibility and had a general set of guidelines to work off of due to my man, NetworkChuck. I was inspired by his video titled:  ["I started a blog.....in 2024 (why you should too)"](https://www.youtube.com/watch?v=dnE7c0ELEH8&t=255s&pp=ygUMbmV0d29ya2NodWNr) 
     
Second, I must also thank you, the reader for being here in the first place. There's a good chance if you've found yourself here, you have that insatiable thirst for new knowledge, making you dig deep and burrow through internet rabbit holes. I say this humbly, as I don't really expect anyone to wind up here and read this. But in the unlikely event you're a human and reading this, I want to express my appreciation that you've given me a chance with your time. Even if you decide the content isn't for you, I'm honored. If you do appreciate the content, have questions or want to share it with someone else who might be interested, well then I'll have greatly exceeded my goals and expectations.

I've always been slightly above-average in terms of tech literacy but haven't had the confidence to jump into less user-friendly experimenting like scripting or learning code, etc. Likely from all the times I got screamed at for messing something up while trying to figure it out as a kid, lol. As anyone who's found this is likely to know, being the family techie is a double-edged sword in the sense that you both get blamed for tech acting up regardless of your true culpability and ambushed for IT troubleshooting, normally for issues that regular maintenance and common-sense best practices would avoid altogether.

Anyways, this felt like a project where I could dip my toe in and get a feel for the basics of network administration without having to worry too much about what I might break on my own hardware. When it comes to NetSec, I've been overwhelmed at times with the sensation that there is a fine line between playing around to learn and doing something that might get you into trouble.

# 
Anyways, on to the main topic here: Optimizing your workflow for posting to a blog. Let's look at what we'll need to get this done!`
	Materials:
	- **Computer**: (can be very limited in its capability. The one I'm using is 15 years old and has no dedicated GPU)
	- I'm using a Debian-based Linux distro here, so the directions are going to be specific to this. 
	-[Obsidian](https://obsidian.md/): install on said computer.
	-Account on hosting service: I used [Netlify](https://www.netlify.com/). NetworkChuck used [Hostinger](https://www.hostinger.com/).
	-Account on [Github](https://github.com/): to store the data that's used to build the site and track changes
	-Hugo: installed on computer. (Compatible with common OS's)
	[Hugo Site](https://gohugo.io/)
	[Hugo Github](https://github.com/gohugoio/hugo)
	

Quick overview of the process when it's complete:`
	1. Write blog post in Obsidian. 
	2. Move it to a specified folder that cues Hugo that it's ready to be posted
	3. Use CLI / Script to stage, commit and push whatever changes that have been added thru Hugo to convert markdown to HTML. 

# 
==***PHASE 1:* Setting up local environment**==

**Install Hugo:**

Purpose: Hugo is the static site generator that will take your Markdown content and static assets and build the HTML website.
Best practices: `sudo apt update` and `sudo apt full-upgrade`
Navigate to the "Installation" section.
Follow the instructions for your operating system (Linux, macOS, Windows) to download and install the Hugo binary. (On Linux you can also just run `sudo apt-get hugo`)
Verification: Open your terminal or command prompt and run `hugo version`. You should see the installed Hugo version information.

## ==**Create a New Hugo Directory:**==

- **Purpose:** This creates the basic directory structure for your Hugo project.
- **Steps:**
    1. Open your terminal or command prompt.
    2. Navigate to the directory where you want to create your blog project (e.g., `/home/user/Documents/My_Project`).
    3. Run the command: `hugo new site My_Project` (or your desired project name).
    - This will create a new directory named `My_Project` with the initial Hugo structure.
**Set up the basic local directory**
This can be done in a way that feels logical to you, as long as the config file and the script point to the right path.
Here's my setup:
You can see under Documents, I have "Obsidian Blog Files" and two sub-folders, one for my Obsidian archive, and the project root. 'Obsidian' was created by the app itself when I made the archive within Obsidian. Project Root was created and named when running `hugo new site My_Project`

It did end up feeling a little redundant in the sense that I could've just made these two sub-folders directly in Documents, but I digress.

![2main_dir](/images/screenshot01.png)
### ==**Choose and Install a Hugo Theme:**==

- **Purpose:** Themes provide the layout, styling, and functionality of your blog.
- **Steps:**
    4. Browse the Hugo Themes website ([https://themes.gohugo.io/](https://themes.gohugo.io/)) to find a theme you like. Consider factors like simplicity, responsiveness, and features.
       Once you've chosen a theme (e.g., "PaperMod"), follow the theme's specific installation instructions. This usually involves:
     5. **Using Git Sub-modules (Recommended):** Navigate into your Hugo project directory (`cd My_Project`). Run: `git init` Then, run: `git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod` (replace the URL with the theme's Git repository URL).

**Note: If you have issues with getting your site to go live and display content, it may be worth swapping themes. Themes play an important role in how the data is parsed and formatted. I tried using Blowfish, and spent a whole night troubleshooting to no avail. I switched to Terminal theme and it worked out of the box.**

#### ==**Configure Hugo:**==

- **Steps:**
    - Navigate to the `themes/<your-theme>/` directory (e.g., `themes/PaperMod/`).
    - Look for an example configuration file (often named `config.toml`, `config.yaml`, or `config.example.toml`).
    - **Copy the contents of this example configuration file** to the `config.toml` file located in the **root** of your Hugo project (`My_Project/config.toml`). If a `config.toml` already exists in the root, you can either replace its contents with the example or carefully merge the necessary settings (especially the `theme = "<your-theme>"` line).
    - **Modify the root `config.toml`** with your site-specific settings like `baseURL`, `languageCode`, `title`, menus, and any other options provided by your chosen theme. Refer to the theme's documentation for available configuration parameters.
    - **Avoid directly editing the `config.toml` file within the `themes/<your-theme>/` directory.**

##### ==**Create Necessary Hugo Directories:**==

- **Purpose:** Ensure the basic content and static directories exist.
- **Steps:** While `hugo new site` creates some, you might need to manually create:
    - `content/posts/`: This is where your blog post Markdown files will go.
    - `static/images/posts/`: This is where the script will copy images linked in your blog posts.
    - `static/docs/`: This is where the script will copy documents linked in your blog posts.
    - You can create these directories using your file manager or terminal commands like `mkdir -p content/posts static/images/posts static/docs`.


# ==***Phase 2*: Setting Up Your Obsidian Vault**==

## Of course, install Obsidian on your machine if needed. 

`sudo apt-get obsidian`

- **Organize Your Notes:** How you'll maintain your blog post drafts and other notes within your Obsidian vault. This is how I arranged mine, but as long as the directories are pointed to correctly in the config files and script, it'll work. 
- **Create the overall archive:** For simplicity, I created two folders within the Documents directory. One for the Obsidian archive, another for the Project root directory. 
- If you intend to use my script, you'll want to make sure the Obsidian directory is set up the same: 

![Obsidian_Dir](/images/screenshot02.png)


### In your shiny new Obsidian archive directory:
- **Create "Ready to Push" Folder:**
    - **Purpose:** This folder acts as a staging area for blog posts that are finalized and ready to be published.
    - **Steps:** Create a new folder within your Obsidian vault named "Ready to Push" (or similar)
- **Create "Static Assets" Folder:**
    - **Purpose:** This folder will contain the static assets (images, documents) that you link to in your blog posts.
    - **Steps:** Create a new folder named "Static Assets" in Obsidian
    - Inside "Static Assets", create two subfolders: "images" and "docs".
- **Create "Published Archive" Folder:**
    - **Purpose:** This folder will store the Markdown files of blog posts that have been successfully published.
    - **Steps:** Create a new folder named "Published Archive" in Obsidian
- **Create "Removed Blog Posts" Folder:**
    - **Purpose:** This folder will store the Markdown files of blog posts that have been removed from the live site.
    - **Steps:** Create a new folder named "Removed Blog Posts" in Obsidian

# ==*Phase 3*: Creating the publish_blog.sh Script==

## Purpose: This script automates the process of moving content from Obsidian to Hugo, building the site, and deploying via Git.

### - - **Steps:**
-Navigate to the `My_Projects` directory in your terminal
-Create a new directory named `scripts`: `mkdir scripts`.
-Copy contents of script and paste into new .sh file, or download from here: 

[publish_blog.sh](https://gist.github.com/millennial-coding/17ccc52385a4ba8541e06681472e81b6)

**Make the Script Executable:**
1. save above script to your project root
2. navigate to the project root in CLI
3.  -In your terminal, navigate to the `My_Project` directory and run: `chmod +x scripts/publish_blog.sh`
**Purpose:** Allows you to run the script.


# ==***Phase 4*: Connecting Hugo to GitHub**==
  
## **Initialize Local Git Repository:**

**Purpose:** To track changes to your Hugo project and enable deployment via Netlify. This creates a local repo on your machine that serves as storage for files that will be pushed to Github and therefore deploy to your blog.
1. In your `My_Project` directory, run: `git init`
2. Go to [Github.com](https://github.com/new) and create an account if needed. Then navigate to the "repositories" section in the top left.
3. Use the same name as your local Hugo project
Do not initialize it with a README, license, or `.gitignore` as you've already done this locally.

### **Create and Use a GitHub Personal Access Token:**

- **Why a Token?** For security, it's recommended to use a Personal Access Token instead of your regular GitHub password for Git operations, especially when automating processes.

- **Steps to Create a Token:**
    1.  Go to your GitHub account in a web browser.
    2.  Click on your profile picture in the top right corner and select **Settings**.
    3.  In the left sidebar, scroll down and click on **Developer settings**.
    4.  In the left sidebar under Developer settings, click on **Personal access tokens** and then **Tokens (classic)**.
    5.  Click on the **Generate new token** button.
    6.  Give your token a descriptive name (e.g., "Hugo Blog Deployment").
    7.  **Important:** Select the necessary scopes (permissions) for this token. At a minimum, you'll need the **`repo`** scope (full control of private repositories). You might also consider `read:org` if you're part of organizations.
    8.  Scroll down and click the **Generate token** button at the bottom.
    9.  **Carefully copy the generated token.** This is the only time you'll see it. Store it in a secure place.

- **Using the Token:** When Git prompts you for your password for GitHub, you will use this generated token instead of your regular account password. Your system's Git credential helper will likely store this token so you don't have to enter it every time.

- **Linking Your Local Repository to GitHub (Revised with Token Consideration):**
    - **Steps:** In your local `My_Projects` directory, run the following commands (replace `YOUR_USERNAME` and `YOUR_REPOSITORY`):

    ```bash
    git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPOSITORY.git
    git branch -M main
    git push -u origin main
    ```

    When you run the `git push` command for the first time, Git might prompt you for your username and password. **Use your GitHub username and the Personal Access Token you just created as the password.** Your Git credential helper should then save this for future use.

# ==Phase 5: Connecting GitHub to Netlify==

## **Sign Up for Netlify:**

- **Purpose:** Netlify will host and automatically build your website.
- **Steps:** Go to [https://www.netlify.com/](https://www.netlify.com/) and sign up for a free account (you can sign up with your GitHub account, Gmail, E-Mail, etc).

## **Create a New Site from Git:**

- **Steps:**
    - Once logged into [Netlify](https://www.netlify.com/), click the "Add new site" button.
    - Select "Deploy with Git".
    - Choose GitHub as your Git provider.
    - Authorize Netlify to access your GitHub repositories if you haven't already.
    - Find and select your `My_Project` repo

## **Configure Build Settings:**

- **Purpose:** Tell Netlify how to build your Hugo site.
- **Steps:** Netlify will usually auto-detect Hugo settings, but verify:
    - **Build command:** `hugo`
    - **Publish directory:** `public`
    - **Branch to deploy:** `main`
    - Click "Deploy site".

# **==Phase 6: Publishing Your First Post (and Subsequent Posts)==**

- **Write Your Blog Post in Obsidian:** Create your first blog post as a Markdown file in your Obsidian vault. Ensure any linked static assets (images, etc.) are placed in the appropriate subfolders within your "Static Assets" folder. Use standard Markdown syntax for links (e.g., `![My Image](image.png)`).
    
- **Move to "Ready to Push":** Once your post is ready, move its `.md` file to the `OBSIDIAN_READY_PATH` (`/home/user/Documents/Obsidian_Blog_Files/Blog Posts Archive/Ready to Push/`). This can be done within Obsidian or from file manager.

***IMPORTANT: make sure you have edited the script first, replacing the placeholder paths with the correct corresponding paths on your local system***
- **Run the `publish_blog.sh` Script:** In your terminal, navigate to the root of your Hugo project (`My_Project) and execute:
`./publish_blog.sh`

This will run the script, copying the files from Obsidian to the Hugo directory, converting to HTML and pushing it all to Github. Then Netlify will automatically detect the changes and apply them to the live website. 

**The last true step is double-checking that it went live! There should be a link on your Netlify profile, something like mynewsite.netlify.app**

And with that, you've built an automated pipeline from your Obsidian notes to a live website, all thanks to the power of Hugo and Netlify. Embrace this workflow, share your passions, and let your voice be heard on the web!
