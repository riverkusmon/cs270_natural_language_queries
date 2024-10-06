require('dotenv').config();
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const OpenAI = require("openai");

const app = express();
const port = 3000;

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

const db = new sqlite3.Database('./restaurant.db', (err) => {
    if (err) {
        console.error('Error connecting to the database', err);
    } else {
        console.log('Connected to SQLite database');
    }
});

app.use(express.json());

app.post('/query', async (req, res) => {
    const userQuestion = req.body.question;

    try {
        const prompt = `You generate only sql and nothing else. There is no formatting on this sql. Return the raw sql text. Generate a SQL query for SQLite that can query for this question: "${userQuestion}". The database has the following tables:

1. **Customers** (customer_id, name, phone_number, email)
2. **Reservations** (reservation_id, customer_id, table_number, reservation_time)
3. **MenuItems** (item_id, name, price, category)
4. **Orders** (order_id, customer_id, item_id, quantity, order_time)

Please ensure the SQL query is correctly formatted for SQLite. Only return the query.`;

        const completion = await openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: [{ role: 'user', content: prompt }],
            max_tokens: 150,
        });

        console.log("Generated SQL Query:", completion.choices[0]);

        const sqlQuery = completion.choices[0].message.content.trim();
        console.log("Generated SQL Query:", sqlQuery);

        db.all(sqlQuery, [], (err, rows) => {
            if (err) {
                console.error('SQL query error:', err.message);
                res.status(400).send("SQL query error: " + err.message);
                return;
            }

            const responsePrompt = `Based on the following data from the database: ${JSON.stringify(rows)}, provide a friendly and concise response to the user's question: "${userQuestion}"`;

            openai.chat.completions.create({
                model: 'gpt-4o-mini',
                messages: [{ role: 'user', content: responsePrompt }],
                max_tokens: 150,
            }).then((completion) => {
                const response = completion.choices[0].message.content.trim();
                res.json({ sqlQuery, response });
            }).catch(gptError => {
                console.error('Error generating friendly response:', gptError);
                res.status(500).send("Error generating response from OpenAI.");
            });
        });

    } catch (gptError) {
        console.error('Error generating SQL query from OpenAI:', gptError);
        res.status(500).send("Error generating SQL query from OpenAI.");
    }
});

app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});
