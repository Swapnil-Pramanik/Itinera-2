const fs = require('fs');
const puppeteer = require('puppeteer');
const marked = require('marked');

async function generatePDF() {
    const mdContent = fs.readFileSync('diagrams.md', 'utf-8');
    
    // Convert Markdown to HTML
    let htmlContent = marked.parse(mdContent);
    
    // Replace <code class="language-mermaid"> with <pre class="mermaid">
    htmlContent = htmlContent.replace(/<pre><code class="language-mermaid">([\s\S]*?)<\/code><\/pre>/g, '<pre class="mermaid">$1</pre>');
    htmlContent = htmlContent.replace(/<code class="language-mermaid">([\s\S]*?)<\/code>/g, '<pre class="mermaid">$1</pre>');
    
    // Setup boilerplate HTML
    const htmlData = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; padding: 20px; line-height: 1.6; color: #333; }
            h1, h2, h3 { border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; margin-top: 24px; margin-bottom: 16px; font-weight: 600; line-height: 1.25; }
            pre { background-color: #f6f8fa; padding: 16px; overflow: auto; border-radius: 6px; }
            table { border-collapse: collapse; width: 100%; margin: 15px 0; }
            th, td { border: 1px solid #dfe2e5; padding: 6px 13px; }
            th { background-color: #f6f8fa; font-weight: 600; }
            tr:nth-child(even) { background-color: #f8f8f8; }
            .mermaid { text-align: center; margin: 20px 0; font-family: 'Courier New', Courier, monospace; }
        </style>
        <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
        <script>
            mermaid.initialize({ startOnLoad: true, htmlLabels: true, securityLevel: 'loose' });
        </script>
    </head>
    <body>
        \${htmlContent}
    </body>
    </html>
    `;
    
    fs.writeFileSync('temp.html', htmlData);
    
    // Run puppeteer using native Chrome and without sandbox
    const browser = await puppeteer.launch({ 
        headless: 'new',
        executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    
    // Load the HTML content
    const fileUrl = 'file://' + __dirname + '/temp.html';
    await page.goto(fileUrl, { waitUntil: 'networkidle0' });
    
    // Render pause for complex mermaid diagrams
    await new Promise(r => setTimeout(r, 3000));
    
    // Wait for mermaid SVGs to appear
    await page.waitForSelector('.mermaid svg', { timeout: 10000 }).catch(() => console.log('Mermaid render timeout'));
    
    // Generate PDF
    await page.pdf({
        path: 'diagrams.pdf',
        format: 'A4',
        printBackground: true,
        margin: { top: '20mm', right: '20mm', bottom: '20mm', left: '20mm' }
    });
    
    await browser.close();
    fs.unlinkSync('temp.html');
    console.log('PDF Generated Successfully!');
}

generatePDF().catch(console.error);
