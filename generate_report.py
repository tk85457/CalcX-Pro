import os
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image
)

def build_pdf(filename="CalcX_Pro_Minor_Project_Report.pdf"):
    # Target A4 size: 595.27 x 841.89 points
    # Margins: 54 pt (0.75 in) left/right, 45 pt top/bottom
    doc = SimpleDocTemplate(
        filename,
        pagesize=A4,
        leftMargin=54,
        rightMargin=54,
        topMargin=45,
        bottomMargin=45
    )

    styles = getSampleStyleSheet()

    # Custom styles matching the LNCT university report
    title_cover = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=24,
        leading=30,
        alignment=1, # Center
        spaceAfter=15
    )

    cover_sub = ParagraphStyle(
        'CoverSub',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=12,
        leading=18,
        alignment=1,
        spaceAfter=8
    )

    cover_bold = ParagraphStyle(
        'CoverBold',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=13,
        leading=18,
        alignment=1,
        spaceAfter=4
    )

    header_univ = ParagraphStyle(
        'HeaderUniv',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=14,
        leading=18,
        alignment=1,
        spaceAfter=4
    )

    header_dept = ParagraphStyle(
        'HeaderDept',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=11,
        leading=16,
        alignment=1,
        spaceAfter=12
    )

    main_heading = ParagraphStyle(
        'MainHeading',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=17,
        leading=22,
        alignment=1,
        spaceAfter=14
    )

    sub_heading = ParagraphStyle(
        'SubHeading',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=11.5,
        leading=15,
        alignment=0, # Left
        spaceBefore=8,
        spaceAfter=3
    )

    body_text = ParagraphStyle(
        'BodyTextCustom',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=10,
        leading=14.2,
        alignment=4, # Justified
        spaceAfter=6
    )

    cert_body = ParagraphStyle(
        'CertBody',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=11,
        leading=17,
        alignment=4,
        spaceAfter=10
    )

    ack_body = ParagraphStyle(
        'AckBody',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=10.5,
        leading=16.5,
        alignment=4,
        spaceAfter=12
    )

    story = []

    # Original logo extracted from the user's reference PDF
    logo_path = "lnct_original_logo_cropped.png"

    # ==========================================
    # PAGE 1: COVER PAGE
    # ==========================================
    story.append(Spacer(1, 25))
    story.append(Paragraph("<b>CALCX PRO</b>", title_cover))
    story.append(Spacer(1, 10))
    story.append(Paragraph("A Minor Project Synopsis Report<br/>Submitted in Partial fulfilment for the award of<br/><b>Diploma in Computer Science & Engineering</b>", cover_sub))
    story.append(Spacer(1, 18))
    story.append(Paragraph("Submitted to<br/><b>LNCT UNIVERSITY</b><br/><b>BHOPAL (M.P)</b>", cover_bold))
    story.append(Spacer(1, 15))

    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=135, height=49.5))
        story.append(Spacer(1, 18))

    story.append(Paragraph("<b>MINOR PROJECT REPORT</b>", ParagraphStyle('ReportSub', parent=title_cover, fontSize=15, leading=20)))
    story.append(Spacer(1, 10))
    story.append(Paragraph("Submitted by", cover_sub))
    story.append(Spacer(1, 8))

    # Authors block: 2 members side by side
    authors_data = [
        [
            Paragraph("<b>Taha Imam</b><br/>[LNCEDPE11060]<br/>Roll No: 40", ParagraphStyle('Auth1', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=15, alignment=1)),
            Paragraph("<b>Md Anas</b><br/>[LNCEDPE11038]<br/>Roll No: 43", ParagraphStyle('Auth2', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=15, alignment=1))
        ]
    ]
    authors_table = Table(authors_data, colWidths=[240, 240])
    authors_table.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 0),
        ('TOPPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(authors_table)

    story.append(Spacer(1, 20))
    story.append(Paragraph("Under the supervision of<br/><b>Vidhya Nishad</b><br/>Lecturer", cover_sub))
    story.append(Spacer(1, 15))

    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=125, height=45.8))
        story.append(Spacer(1, 12))

    story.append(Paragraph("School of Computer Science and Technology<br/><b>LNCT UNIVERSITY</b><br/><b>BHOPAL (M.P)</b>", cover_bold))
    story.append(Spacer(1, 8))
    story.append(Paragraph("Session july-dec2026", cover_sub))
    story.append(PageBreak())

    # ==========================================
    # PAGE 2: CERTIFICATE
    # ==========================================
    story.append(Spacer(1, 15))
    story.append(Paragraph("<b>LNCT UNIVERSITY</b>", header_univ))
    story.append(Paragraph("School of Computer Science and Technology", header_dept))

    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=130, height=47.7))
        story.append(Spacer(1, 18))

    story.append(Paragraph("<b>CERTIFICATE</b>", main_heading))
    story.append(Spacer(1, 15))

    cert_text = (
        "This is to certify that the work embodied in this Minor Project work entitled "
        "<b>”CalcX Pro - A Smart Multi-Functional Calculator and Utility Suite”</b> has been satisfactorily "
        "completed by <b>Taha Imam (LNCEDPE11060, Roll No: 40)</b> and <b>Md Anas (LNCEDPE11038, Roll No: 43)</b>. "
        "It is a bonafide piece of work, carried out under the guidance from the "
        "<b>School of Computer Science and Technology, LNCT UNIVERSITY, Bhopal</b> for the partial "
        "fulfilment of the award of <b>Diploma in Computer Science & Engineering</b> during the academic year 2026."
    )
    story.append(Paragraph(cert_text, cert_body))
    story.append(Spacer(1, 75))

    # Supervisor Signature
    story.append(Paragraph("<b>Vidhya Nishad</b><br/>Lecturer (Project Guide)", ParagraphStyle('GuideSign', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=15, alignment=1)))
    story.append(Spacer(1, 70))

    # Forwarded & Approved
    signs_data = [
        [
            Paragraph("<b>Forwarded By</b><br/><br/><br/><b>Prof. & Head</b><br/>School of Computer Science and Technology", ParagraphStyle('Sign1', parent=styles['Normal'], fontName='Times-Roman', fontSize=10, leading=14, alignment=1)),
            Paragraph("<b>Approved By</b><br/><br/><br/><b>Principal</b><br/>School of Computer Science and Technology", ParagraphStyle('Sign2', parent=styles['Normal'], fontName='Times-Roman', fontSize=10, leading=14, alignment=1))
        ]
    ]
    signs_table = Table(signs_data, colWidths=[240, 240])
    signs_table.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'BOTTOM'),
    ]))
    story.append(signs_table)
    story.append(PageBreak())

    # ==========================================
    # PAGE 3: ACKNOWLEDGEMENT
    # ==========================================
    story.append(Spacer(1, 15))
    story.append(Paragraph("<b>LNCT UNIVERSITY</b>", header_univ))
    story.append(Paragraph("School of Computer Science and Technology", header_dept))

    if os.path.exists(logo_path):
        story.append(Image(logo_path, width=130, height=47.7))
        story.append(Spacer(1, 18))

    story.append(Paragraph("<b>ACKNOWLEDGEMENT</b>", main_heading))
    story.append(Spacer(1, 15))

    ack_p1 = (
        "We express our deep sense of gratitude to <b>Prof. Vidhya Nishad</b>, Department of "
        "School of Computer Science and Technology, LNCT UNIVERSITY, Bhopal, whose valuable guidance, "
        "encouraging attitude, and timely constructive feedback guided us throughout the development of this project. "
        "Her consistent mentoring provided clarity and direction at every stage."
    )
    story.append(Paragraph(ack_p1, ack_body))

    ack_p2 = (
        "A special thank goes to <b>Dr. Bhupesh Gour</b>, Prof. & Head of Department, who helped us by providing "
        "vital academic suggestions and departmental resources in completing this project work. He exchanged his "
        "innovative ideas & thoughts regarding mobile application engineering, performance optimization, and project structuring, "
        "which made this project work successful."
    )
    story.append(Paragraph(ack_p2, ack_body))

    ack_p3 = (
        "We are equally grateful to <b>Dr. A.K Sachan</b>, Principal, SOCST, LNCTU, for providing an excellent academic "
        "environment and all the necessary technical infrastructure, computing laboratories, and institutional resources to carry out this work."
    )
    story.append(Paragraph(ack_p3, ack_body))

    ack_p4 = (
        "Finally, we would also extend our heartfelt thanks to our institution, laboratory technicians, and all faculty members "
        "without whose generous support and encouragement this project work would have remained an unfulfilled dream."
    )
    story.append(Paragraph(ack_p4, ack_body))
    story.append(Spacer(1, 45))

    ack_signatures = [
        [
            Paragraph("<b>Taha Imam</b><br/>[LNCEDPE11060]<br/>Roll No: 40", ParagraphStyle('AckAuth1', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=15, alignment=1)),
            Paragraph("<b>Md Anas</b><br/>[LNCEDPE11038]<br/>Roll No: 43", ParagraphStyle('AckAuth2', parent=styles['Normal'], fontName='Times-Roman', fontSize=10.5, leading=15, alignment=1))
        ]
    ]
    ack_sig_table = Table(ack_signatures, colWidths=[240, 240])
    ack_sig_table.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(ack_sig_table)
    story.append(PageBreak())

    # ==========================================
    # PAGE 4: ABSTRACT
    # ==========================================
    story.append(Spacer(1, 20))
    story.append(Paragraph("<b>Abstract</b>", ParagraphStyle('AbsHeading', parent=main_heading, fontSize=18, spaceAfter=20)))

    abs_p1 = (
        "<b>CalcX Pro</b> is an advanced, multi-functional smart calculator and mathematical utility application "
        "developed to simplify and streamline complex numerical workflows on modern mobile devices. In today’s digital era, "
        "students, educators, financial professionals, and daily consumers frequently need to perform varied computational tasks—ranging "
        "from routine arithmetic and scientific problem-solving to financial loan assessments (EMI), tax computations (GST), "
        "currency conversions, and unit transformations. Traditional mobile calculators are usually restricted to elementary arithmetic, "
        "forcing users to juggle multiple isolated third-party tools, which introduces latency, visual clutter, and privacy concerns."
    )
    story.append(Paragraph(abs_p1, body_text))

    abs_p2 = (
        "The main objective of the <b>CalcX Pro</b> project is to deliver a unified, highly optimized, and elegant computational suite. "
        "The application integrates an intuitive basic calculator, an extensive scientific computing engine with mathematical expression parsing, "
        "and a specialized commercial suite comprising EMI, GST, Income Tax, Discount, Percentage, Age, and Body Mass Index (BMI) calculators. "
        "Furthermore, it incorporates an adaptable multi-category unit converter and a live currency exchange module with local caching."
    )
    story.append(Paragraph(abs_p2, body_text))

    abs_p3 = (
        "The project focuses on <b>computational precision, instantaneous responsiveness, offline-first reliability, and accessibility</b>. "
        "Built on the Flutter cross-platform framework utilizing the Dart programming language, the system employs reactive state management "
        "via the Provider pattern and high-speed local persistence through the Hive NoSQL database for session and calculation history tracking. "
        "A dynamic multi-theme engine featuring 24+ color palettes (including true AMOLED black) and subtle tactile haptic feedback offers an engaging user experience."
    )
    story.append(Paragraph(abs_p3, body_text))

    abs_p4 = (
        "Overall, <b>CalcX Pro</b> eliminates software fragmentation by combining professional-grade computing tools into a single, cohesive, "
        "and privacy-preserving mobile solution. It represents a practical synthesis of key computer science principles—including tokenization, "
        "expression tree evaluation, reactive state propagation, local NoSQL indexing, and human-computer interaction (HCI) design."
    )
    story.append(Paragraph(abs_p4, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 5: INDEX
    # ==========================================
    story.append(Spacer(1, 20))
    story.append(Paragraph("<b>Index</b>", ParagraphStyle('IdxHeading', parent=main_heading, fontSize=18, spaceAfter=22)))

    index_rows = [
        [Paragraph("<b>S.No.</b>", ParagraphStyle('Th1', fontName='Times-Bold', fontSize=10.5, alignment=1)),
         Paragraph("<b>TOPICS</b>", ParagraphStyle('Th2', fontName='Times-Bold', fontSize=10.5, alignment=1)),
         Paragraph("<b>No. of Pages</b>", ParagraphStyle('Th3', fontName='Times-Bold', fontSize=10.5, alignment=1))],
        ["1.", "Introduction", "1"],
        ["2.", "Problem Domain", "1-2"],
        ["3.", "Solution Domain", "2-3"],
        ["4.", "Literature Survey", "3-4"],
        ["5.", "Existing System", "4-5"],
        ["6.", "Proposed System", "5-8"],
        ["7.", "System Requirements & Technology Used", "8-10"],
        ["8.", "System Design & Methodology", "10-13"],
        ["9.", "Advantages, Applications & Future Scope", "13-15"],
        ["10.", "References", "15-16"]
    ]

    index_table = Table(index_rows, colWidths=[55, 335, 95])
    index_table.setStyle(TableStyle([
        ('GRID', (0,0), (-1,-1), 0.7, colors.black),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('ALIGN', (0,0), (0,-1), 'CENTER'),
        ('ALIGN', (2,0), (2,-1), 'CENTER'),
        ('FONTNAME', (0,0), (-1,-1), 'Times-Roman'),
        ('FONTSIZE', (0,0), (-1,-1), 10.5),
        ('TOPPADDING', (0,0), (-1,-1), 6.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6.5),
        ('LEFTPADDING', (1,1), (1,-1), 14),
    ]))
    story.append(index_table)
    story.append(PageBreak())

    # ==========================================
    # PAGE 6: 1. INTRODUCTION
    # ==========================================
    story.append(Paragraph("<b>1.INTRODUCTION</b>", main_heading))

    intro_p1 = (
        "In modern everyday life and professional domains, numerical calculations form an essential part of decision-making. "
        "Whether in an educational institution, a commercial marketplace, an engineering laboratory, or home finance management, "
        "individuals constantly handle arithmetic operations, statistical formulas, physical unit conversions, and financial evaluations. "
        "With the rapid penetration of smartphones, handheld digital devices have replaced dedicated hardware calculators, "
        "becoming the primary interface for solving mathematical tasks on the go."
    )
    story.append(Paragraph(intro_p1, body_text))

    intro_p2 = (
        "<b>CalcX Pro</b> is an all-in-one, high-performance mobile calculation suite designed to address the fragmented nature "
        "of existing mobile tools. Rather than restricting users to standard four-function arithmetic, CalcX Pro unifies standard calculation, "
        "scientific analysis, commercial finance computation (EMI, GST, Tax, Discount), personal metric assessments (Age, BMI), "
        "multi-dimensional unit conversions, and foreign currency calculations within an intuitive, cohesive ecosystem."
    )
    story.append(Paragraph(intro_p2, body_text))

    intro_p3 = (
        "The system incorporates real-time expression evaluation, interactive syntax validation, and automated parenthesis balancing. "
        "Through a persistent calculation history drawer powered by a local lightweight database, users can easily review, trace, "
        "and reuse previous results without fear of data loss during app minimization or restart."
    )
    story.append(Paragraph(intro_p3, body_text))

    intro_p4 = (
        "CalcX Pro is built using a modern touch-first design philosophy. It incorporates smooth micro-animations, customizable "
        "vibrational haptic feedback, and a versatile multi-theme engine featuring 24 curated palettes. This guarantees optimal contrast, "
        "ergonomic readability, and high user comfort across varying lighting conditions, including high-efficiency dark themes for battery saving."
    )
    story.append(Paragraph(intro_p4, body_text))

    intro_p5 = (
        "From an academic standpoint, the project demonstrates the practical implementation of core Computer Science principles, "
        "including lexical tokenization, mathematical parsing trees, reactive state management using the Provider pattern, "
        "asynchronous REST API consumption with caching, and local NoSQL key-value persistence using Hive. The system is designed "
        "to be completely modular, extensible, and cross-platform ready."
    )
    story.append(Paragraph(intro_p5, body_text))

    intro_p6 = (
        "Overall, <b>CalcX Pro</b> offers a dependable, distraction-free, and comprehensive computational companion. "
        "By merging mathematical rigor with refined human-computer interaction (HCI), the project establishes a new benchmark for "
        "practical utility applications in mobile computing."
    )
    story.append(Paragraph(intro_p6, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 7: 2. PROBLEM DOMAIN
    # ==========================================
    story.append(Paragraph("<b>2.PROBLEM DOMAIN</b>", main_heading))

    story.append(Paragraph("2.1 Fragmentation of Computational Utilities", sub_heading))
    p_2_1 = (
        "Mobile device users are forced to install and juggle separate dedicated applications for different tasks: "
        "a stock calculator for simple arithmetic, a separate scientific calculator app for trigonometry, an EMI loan calculator "
        "for banking, a unit converter for engineering, and an internet browser for currency rates. This fragmentation wastes "
        "device memory, complicates user workflows, and leads to severe context switching."
    )
    story.append(Paragraph(p_2_1, body_text))

    story.append(Paragraph("2.2 Cluttered Interface and Sluggish Response in Complex Apps", sub_heading))
    p_2_2 = (
        "Many multi-tool calculation apps available on mobile stores suffer from overly complicated menus, confusing nested options, "
        "and excessive background processes. These heavy background services cause noticeable input latency, drain device battery, "
        "and result in sluggish frame rates during continuous calculations."
    )
    story.append(Paragraph(p_2_2, body_text))

    story.append(Paragraph("2.3 Lack of Calculation History and Accidental Loss of Data", sub_heading))
    p_2_3 = (
        "Standard pre-installed mobile calculators clear input expressions immediately upon pressing 'Clear' (C) or when the app "
        "is closed or purged from RAM. When users perform chained multi-step calculations, losing the historical audit trail causes "
        "frustration, requiring them to manually restart the entire arithmetic sequence on paper."
    )
    story.append(Paragraph(p_2_3, body_text))

    story.append(Paragraph("2.4 Ineffective Syntax Handling and Rigid Evaluation", sub_heading))
    p_2_4 = (
        "Conventional calculators strictly demand exact syntax. If a user accidentally enters duplicate operators (e.g., '5++2') "
        "or forgets to close nested parentheses, the application immediately outputs a generic 'Error' message without offering "
        "smart operator replacement, real-time live previewing, or automated bracket resolution."
    )
    story.append(Paragraph(p_2_4, body_text))

    story.append(Paragraph("2.5 Inflexible Themes and Poor Visual Accessibility", sub_heading))
    p_2_5 = (
        "Most stock calculators offer a rigid user interface with limited visual customization. Users working under direct sunlight "
        "or in dimly lit study spaces struggle with fixed low-contrast button palettes. The lack of dynamic theming "
        "and tactile haptic feedback prevents an accessible, comfortable user experience."
    )
    story.append(Paragraph(p_2_5, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 8: 3. SOLUTION DOMAIN
    # ==========================================
    story.append(Paragraph("<b>3.SOLUTION DOMAIN</b>", main_heading))

    story.append(Paragraph("3.1 Unified Multi-Mode Architecture", sub_heading))
    p_3_1 = (
        "The CalcX Pro project presents a unified, multi-tiered computational platform where users can access basic math, "
        "scientific analysis, commercial finance modules, and physical unit conversions under a single coherent interface. "
        "This completely eliminates the need for downloading fragmented utility tools, saving device storage and streamlining workflow."
    )
    story.append(Paragraph(p_3_1, body_text))

    story.append(Paragraph("3.2 Persistent Local History Engine", sub_heading))
    p_3_2 = (
        "By integrating an embedded high-speed NoSQL database (Hive), CalcX Pro records every completed calculation with its "
        "exact expression, evaluated result, and timestamp. A dedicated slide-out history drawer allows users to review, "
        "search, copy, or recall past computations back onto the active display."
    )
    story.append(Paragraph(p_3_2, body_text))

    story.append(Paragraph("3.3 Intelligent Real-Time Parser and Auto-Calculation", sub_heading))
    p_3_3 = (
        "The system incorporates an intelligent expression parser that provides real-time live evaluation as characters are typed. "
        "It features auto-replacing operator handling (e.g., smoothly overwriting a '+' with a '×'), smart unary sign insertion, "
        "and automated closing bracket synthesis upon pressing the equals button, ensuring error-free calculations."
    )
    story.append(Paragraph(p_3_3, body_text))

    story.append(Paragraph("3.4 Specialized Commercial and Daily Utilities Suite", sub_heading))
    p_3_4 = (
        "CalcX Pro includes dedicated calculation engines for EMI loan estimation (with principal and interest breakdowns), "
        "GST calculations (exclusive and inclusive tax slabs), Discount computations, Age differences, and BMI health ratings, "
        "all built with customized user-friendly input controls."
    )
    story.append(Paragraph(p_3_4, body_text))

    story.append(Paragraph("3.5 Offline-First Reliability and Customizable Ergonomics", sub_heading))
    p_3_5 = (
        "The application operates fully offline with complete user privacy and zero unnecessary network traffic. It includes a comprehensive "
        "theming engine with 24 curated themes, dark/light toggle, and subtle haptic feedback, ensuring privacy, speed, "
        "and an ergonomic experience for all users."
    )
    story.append(Paragraph(p_3_5, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 9: 4. LITERATURE SURVEY
    # ==========================================
    story.append(Paragraph("<b>4.LITERATURE SURVEY</b>", main_heading))

    lit_p_intro = (
        "The literature survey for the <b>CalcX Pro</b> project focuses on the evolution of digital computing utilities, "
        "modern mathematical parsing algorithms, cross-platform mobile frameworks, and human-computer interaction (HCI) standards. "
        "Existing systems and technical methodologies were thoroughly researched to identify architectural strengths and functional gaps."
    )
    story.append(Paragraph(lit_p_intro, body_text))

    story.append(Paragraph("4.1 Evolution of Digital and Mobile Calculators", sub_heading))
    p_4_1 = (
        "From early mechanical calculators like the Pascaline and abacus to electronic desktop devices in the 1970s, calculators have "
        "continually adapted to emerging technology. With smartphones becoming ubiquitous, digital calculator apps have largely replaced "
        "standalone hardware. However, most stock smartphone calculators still replicate 1980s physical button layouts, "
        "ignoring modern gesture navigation and dynamic display capabilities."
    )
    story.append(Paragraph(p_4_1, body_text))

    story.append(Paragraph("4.2 Expression Parsing and Mathematical Evaluation Algorithms", sub_heading))
    p_4_2 = (
        "Academic literature highlights Dijkstra’s Shunting-yard algorithm and recursive descent parsing for converting infix mathematical "
        "expressions into Postfix (Reverse Polish Notation) or Abstract Syntax Trees (AST). Modern mobile engines leverage these principles "
        "to ensure strict adherence to operator precedence (PEMDAS/BODMAS), accurate handling of trigonometric identities, and reliable floating-point precision."
    )
    story.append(Paragraph(p_4_2, body_text))

    story.append(Paragraph("4.3 Local Data Persistence and Lightweight Mobile Storage", sub_heading))
    p_4_3 = (
        "Studies on mobile software engineering show that traditional relational databases like SQLite introduce unnecessary ORM overhead "
        "for simple key-value and append-heavy data logs. Pure Dart NoSQL storage solutions, such as Hive, store binary-serialized objects directly "
        "into indexed box structures, providing sub-millisecond read/write speeds with zero native bridge overhead."
    )
    story.append(Paragraph(p_4_3, body_text))

    story.append(Paragraph("4.4 Reactive State Management in Cross-Platform UI Frameworks", sub_heading))
    p_4_4 = (
        "Research in modern declarative UI frameworks (such as Flutter and React Native) emphasizes that decoupling business logic from "
        "widget rendering via reactive state containers (e.g., ChangeNotifier and Provider) avoids redundant rebuilds, lowers CPU utilization, "
        "and ensures consistent 60+ FPS rendering across low-end and high-end hardware."
    )
    story.append(Paragraph(p_4_4, body_text))

    story.append(Paragraph("4.5 Summary of Findings and Scope for CalcX Pro", sub_heading))
    p_4_5 = (
        "The literature survey confirms that while individual calculator, converter, and financial tools exist, there is a clear "
        "opportunity for a unified, lightweight, and privacy-respecting application that integrates these diverse utilities into a cohesive, "
        "high-performance mobile architecture."
    )
    story.append(Paragraph(p_4_5, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 10: 5. EXISTING SYSTEM
    # ==========================================
    story.append(Paragraph("<b>5.EXISTING SYSTEM</b>", main_heading))

    story.append(Paragraph("5.1 Native Default Operating System Calculators", sub_heading))
    p_5_1 = (
        "Pre-installed calculators on Android and iOS offer basic arithmetic and a rudimentary scientific mode. However, they lack "
        "essential utilities such as loan EMI calculations, GST tax computation, body metrics, and customized history organization, "
        "severely limiting their usefulness for non-academic or financial tasks."
    )
    story.append(Paragraph(p_5_1, body_text))

    story.append(Paragraph("5.2 Standalone Specialized Utility Applications", sub_heading))
    p_5_2 = (
        "Specialized mobile apps exist for isolated tasks (such as individual currency converters, mortgage calculators, or health apps). "
        "However, maintaining multiple single-purpose apps increases phone storage consumption, clutters the app drawer, and disrupts the "
        "user's computational workflow."
    )
    story.append(Paragraph(p_5_2, body_text))

    story.append(Paragraph("5.3 Web-Based Online Calculators", sub_heading))
    p_5_3 = (
        "Many users rely on search engines or financial websites for specialized conversions. These web portals require constant high-speed "
        "internet connectivity, consume mobile data, take seconds to load, and are frequently cluttered with third-party tracking scripts, "
        "making them impractical for quick daily calculations."
    )
    story.append(Paragraph(p_5_3, body_text))

    story.append(Paragraph("5.4 Generic Multi-Tool Portals and Complex Utilities", sub_heading))
    p_5_4 = (
        "Several multi-tool utility packages attempt to offer numerous features but suffer from convoluted navigation trees, slow startup "
        "delays, and unnecessary background resource polling, making rapid calculations cumbersome on standard handheld devices."
    )
    story.append(Paragraph(p_5_4, body_text))

    story.append(Paragraph("5.5 Limitations of Existing Systems", sub_heading))
    p_5_5 = (
        "In summary, existing solutions suffer from significant shortcomings: tool fragmentation, lack of comprehensive offline capabilities, "
        "heavy background battery drain, absence of persistent history logging, rigid syntax error handling, and minimal visual accessibility. "
        "These limitations highlight the clear need for a unified, modern, and privacy-first solution like <b>CalcX Pro</b>."
    )
    story.append(Paragraph(p_5_5, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 11: 6. PROPOSED SYSTEM (Part 1)
    # ==========================================
    story.append(Paragraph("<b>6.PROPOSED SYSTEM</b>", main_heading))

    story.append(Paragraph("6.1 Overview of the Proposed System", sub_heading))
    p_6_1 = (
        "The proposed system, <b>CalcX Pro</b>, is a unified, high-performance mobile application engineered to provide a comprehensive "
        "suite of computational, financial, and daily utility tools. Developed with Flutter and Dart, the application offers a clean, "
        "responsive, and privacy-preserving experience with instantaneous calculation speeds."
    )
    story.append(Paragraph(p_6_1, body_text))

    story.append(Paragraph("6.2 Basic Arithmetic Calculator Module", sub_heading))
    p_6_2 = (
        "The basic calculator module handles everyday arithmetic (+, -, ×, ÷, %, ±). It incorporates live auto-calculation, "
        "dynamic operator replacement, and responsive font resizing that adjusts seamlessly to prevent text clipping as mathematical expressions grow."
    )
    story.append(Paragraph(p_6_2, body_text))

    story.append(Paragraph("6.3 Advanced Scientific Computing Engine", sub_heading))
    p_6_3 = (
        "The scientific module provides full support for advanced mathematics: trigonometric (sin, cos, tan) and inverse trigonometric functions, "
        "natural and base-10 logarithms, power exponents (x², x³, xʸ), square and cube roots, absolute values (|x|), factorials (!), "
        "and mathematical constants (π, e), evaluated via an Abstract Syntax Tree (AST)."
    )
    story.append(Paragraph(p_6_3, body_text))

    story.append(Paragraph("6.4 Financial Computing Suite (EMI, GST, Tax & Discount)", sub_heading))
    p_6_4 = (
        "CalcX Pro includes dedicated financial calculators: an EMI Loan Calculator (computing monthly installments, total interest, and total payable), "
        "a GST Calculator with standard rates (5%, 12%, 18%, 28%), an Income Tax slab evaluator, and a Discount & Percentage calculator "
        "for instant retail calculations."
    )
    story.append(Paragraph(p_6_4, body_text))

    story.append(Paragraph("6.5 Daily Utility Modules (Age & BMI Calculators)", sub_heading))
    p_6_5 = (
        "The system incorporates practical daily tools: an Age Calculator providing exact breakdowns of years, months, and days, "
        "and a Body Mass Index (BMI) Calculator that evaluates health status according to World Health Organization (WHO) weight categories."
    )
    story.append(Paragraph(p_6_5, body_text))

    story.append(Paragraph("6.6 Multi-Category Unit Converter", sub_heading))
    p_6_6 = (
        "The unit converter offers instantaneous, bidirectional conversions across multiple physical dimensions, including Length "
        "(meter, kilometer, centimeter, inch, foot, mile), Weight (kg, gram, pound, ounce), Temperature (°C, °F, Kelvin), and Area."
    )
    story.append(Paragraph(p_6_6, body_text))

    story.append(Paragraph("6.7 Currency Converter with REST API and Offline Caching", sub_heading))
    p_6_7 = (
        "The currency converter fetches live foreign exchange rates via a dedicated REST API, while automatically caching the latest rates "
        "locally to allow seamless conversions even when the device is completely offline."
    )
    story.append(Paragraph(p_6_7, body_text))

    story.append(Paragraph("6.8 Persistent History Drawer and Audit Trail", sub_heading))
    p_6_8 = (
        "A slide-out history drawer records every evaluated calculation, displaying expressions alongside their results and timestamps. "
        "Users can tap any entry to recall it to the active display, copy results to the clipboard, or clear the history."
    )
    story.append(Paragraph(p_6_8, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 12: 6. PROPOSED SYSTEM (Part 2)
    # ==========================================
    story.append(Paragraph("6.9 Real-Time Dynamic Auto-Calculation & Syntax Sanitization", sub_heading))
    p_6_9 = (
        "Unlike conventional calculators that require pressing the equals button after every step, CalcX Pro continuously evaluates expressions "
        "in real time. The engine automatically handles operator replacements, balances unclosed brackets, and sanitizes input to prevent runtime errors."
    )
    story.append(Paragraph(p_6_9, body_text))

    story.append(Paragraph("6.10 Adaptive Multi-Theme Engine & Accessibility", sub_heading))
    p_6_10 = (
        "CalcX Pro includes a comprehensive theming system offering 24 predefined color palettes, spanning Ocean Blue, Forest Green, "
        "Sunset Orange, Royal Purple, and Pure Black (AMOLED). This ensures high visual contrast, reduces eye strain, and optimizes battery consumption."
    )
    story.append(Paragraph(p_6_10, body_text))

    story.append(Paragraph("6.11 Tactile Haptic Feedback and Interactive Controls", sub_heading))
    p_6_11 = (
        "Every button press triggers subtle, calibrated vibration haptic feedback through the device's hardware vibrator, providing physical "
        "confirmation of input and significantly minimizing keystroke errors during rapid entry."
    )
    story.append(Paragraph(p_6_11, body_text))

    story.append(Paragraph("6.12 Gesture-Friendly Navigation and Ergonomics", sub_heading))
    p_6_12 = (
        "The interface features a gesture-enabled tabbed layout that allows users to switch between Basic, Scientific, and Advanced utility grids "
        "with smooth transitions, paired with an accessible navigation drawer for rapid access to all tools."
    )
    story.append(Paragraph(p_6_12, body_text))

    story.append(Paragraph("6.13 Future Enhancement and Scalability", sub_heading))
    p_6_13 = (
        "The modular architecture of CalcX Pro enables straightforward future enhancements, such as OCR camera math recognition, "
        "2D/3D function graphing, exportable financial PDF reports, and cloud synchronization across multiple devices."
    )
    story.append(Paragraph(p_6_13, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 13: 7. SYSTEM REQUIREMENTS & TECHNOLOGY USED (Part 1)
    # ==========================================
    story.append(Paragraph("<b>7.SYSTEM REQUIREMENTS &amp; TECHNOLOGY USED</b>", main_heading))

    story.append(Paragraph("7.1 Hardware Requirements", sub_heading))
    p_7_1 = (
        "<b>Development Workstation:</b> Intel Core i3 / AMD Ryzen 3 processor or higher, minimum 8 GB RAM (16 GB recommended), "
        "and at least 10 GB of available SSD storage space.<br/>"
        "<b>Target Mobile Device:</b> Any Android smartphone or tablet running Android 5.0 (API Level 21) or above, "
        "with a minimum of 1 GB RAM and 60 MB of free storage space."
    )
    story.append(Paragraph(p_7_1, body_text))

    story.append(Paragraph("7.2 Software Requirements", sub_heading))
    p_7_2 = (
        "<b>Operating System:</b> Windows 10/11, macOS, or 64-bit Linux distribution.<br/>"
        "<b>SDKs &amp; Runtimes:</b> Flutter SDK (v3.4.0 or above), Dart SDK (v3.0.0 to v4.0.0), Java Development Kit (JDK 17).<br/>"
        "<b>Build Tools:</b> Android SDK (compileSdk 36, targetSdk 35), Gradle 8.14, Kotlin 2.2."
    )
    story.append(Paragraph(p_7_2, body_text))

    story.append(Paragraph("7.3 Flutter Framework &amp; Dart Language", sub_heading))
    p_7_3 = (
        "Flutter is Google’s open-source UI software development kit. It compiles directly to native ARM machine code using its Skia/Impeller "
        "graphics engine, delivering smooth 60+ FPS performance without JavaScript bridge overhead. Dart provides strong typing, ahead-of-time (AOT) "
        "compilation, and efficient garbage collection."
    )
    story.append(Paragraph(p_7_3, body_text))

    story.append(Paragraph("7.4 Reactive State Management (Provider Pattern)", sub_heading))
    p_7_4 = (
        "The Provider package is employed to manage application state predictably. It decouples core mathematical calculation logic from "
        "widget rendering, notifying listeners only when state variables change, which minimizes unnecessary widget rebuilds."
    )
    story.append(Paragraph(p_7_4, body_text))

    story.append(Paragraph("7.5 Local Database (Hive NoSQL Key-Value Store)", sub_heading))
    p_7_5 = (
        "Hive is an exceptionally fast, lightweight NoSQL key-value database written in pure Dart. It stores binary-serialized calculation "
        "history records locally without native dependencies, ensuring instantaneous read/write operations and full offline persistence."
    )
    story.append(Paragraph(p_7_5, body_text))

    story.append(Paragraph("7.6 Mathematical Evaluation Engine (math_expressions)", sub_heading))
    p_7_6 = (
        "The math_expressions package parses complex infix arithmetic strings into Abstract Syntax Trees (AST). It accurately resolves "
        "operator precedence, evaluates scientific functions, and safely handles edge cases like division-by-zero."
    )
    story.append(Paragraph(p_7_6, body_text))

    story.append(Paragraph("7.7 Networking &amp; External REST APIs", sub_heading))
    p_7_7 = (
        "The HTTP networking client communicates asynchronously with public exchange rate APIs to fetch current foreign currency rates, "
        "deserializing JSON responses into local data models while gracefully handling network timeouts."
    )
    story.append(Paragraph(p_7_7, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 14: 7. SYSTEM REQUIREMENTS & TECHNOLOGY USED (Part 2)
    # ==========================================
    story.append(Paragraph("7.8 Device Hardware &amp; Platform Channel Integration", sub_heading))
    p_7_8 = (
        "The application integrates with native Android platform channels through specialized Flutter plugins. The <b>vibration</b> plugin "
        "communicates with Android’s Vibrator service to provide tactile feedback on button presses. The <b>path_provider</b> package secures "
        "isolated sandboxed directory paths for Hive storage, while <b>SystemChrome</b> customizes system overlay styles for immersive edge-to-edge display."
    )
    story.append(Paragraph(p_7_8, body_text))

    story.append(Paragraph("7.9 Development Tools and Testing Utilities", sub_heading))
    p_7_9 = (
        "The project was engineered and maintained using industry-standard tools:<br/>"
        "• <b>Visual Studio Code / Android Studio:</b> Primary IDEs featuring Dart analysis, Flutter DevTools, and real-time debugging.<br/>"
        "• <b>Flutter CLI:</b> Command-line interface for dependency resolution, static code analysis (flutter analyze), and release builds.<br/>"
        "• <b>Android Debug Bridge (ADB):</b> Tool for real-time log tracking, performance profiling, and direct APK installation on physical test devices.<br/>"
        "• <b>Git:</b> Distributed version control system used for managing source code revisions."
    )
    story.append(Paragraph(p_7_9, body_text))

    story.append(Paragraph("7.10 Code Optimization, Tree-Shaking, and Release Packaging", sub_heading))
    p_7_10 = (
        "To achieve a lean production build, CalcX Pro utilizes advanced compilation optimizations:<br/>"
        "• <b>Icon Font Tree-Shaking:</b> Automatically strips unreferenced glyphs from font assets, reducing font payload size by over 99%.<br/>"
        "• <b>ProGuard / R8 Minification:</b> Enabled in release builds to obfuscate source code, strip unused bytecode, and optimize runtime performance.<br/>"
        "• <b>Resource Shrinking:</b> Automatically removes unused resources from packaged Android binaries.<br/>"
        "• <b>Signing &amp; Distribution Formats:</b> Signed with release keystores using V1-V4 schemes, producing production-ready APK and Android App Bundle (.aab) packages."
    )
    story.append(Paragraph(p_7_10, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 15: 8. SYSTEM DESIGN & METHODOLOGY (Part 1)
    # ==========================================
    story.append(Paragraph("<b>8.SYSTEM DESIGN &amp; METHODOLOGY</b>", main_heading))

    story.append(Paragraph("8.1 Layered System Architecture", sub_heading))
    p_8_1 = (
        "CalcX Pro follows a modular four-tier software architecture that enforces a clean separation of concerns:<br/>"
        "1. <b>Presentation Layer (UI):</b> Material 3 widgets, interactive buttons, responsive display panels, and drawers.<br/>"
        "2. <b>State Management Layer:</b> Providers (CalculatorProvider, ThemeProvider, HistoryProvider, SettingsProvider) coordinating business logic.<br/>"
        "3. <b>Service &amp; Evaluation Engine:</b> Mathematical parser (CalculatorUtils), currency service, and unit conversion algorithms.<br/>"
        "4. <b>Data &amp; Persistence Layer:</b> Hive box storage managing persistent history logs and user preferences."
    )
    story.append(Paragraph(p_8_1, body_text))

    story.append(Paragraph("8.2 Expression Tokenization and Evaluation Pipeline", sub_heading))
    p_8_2 = (
        "When an input is registered, it passes through a four-stage pipeline: (1) <i>Sanitization &amp; Smart Substitution</i> (handling operator overwrites), "
        "(2) <i>Lexical Tokenization</i> (identifying numbers, operators, and functions), (3) <i>AST Construction</i> (validating parentheses and precedence), "
        "and (4) <i>Numerical Evaluation &amp; Formatting</i> (generating formatted results and dispatching to history storage)."
    )
    story.append(Paragraph(p_8_2, body_text))

    story.append(Paragraph("8.3 Reactive State and Data Flow", sub_heading))
    p_8_3 = (
        "The reactive data flow follows a unidirectional cycle. User interactions dispatch actions to the CalculatorProvider, "
        "which processes the calculation, updates internal state, and broadcasts notifications to listening widgets via notifyListeners(), "
        "ensuring immediate display updates without blocking the main UI thread."
    )
    story.append(Paragraph(p_8_3, body_text))

    story.append(Paragraph("8.4 Database Schema &amp; History Model Design", sub_heading))
    p_8_4 = (
        "History records are modeled via a structured HistoryEntry class serialized through a generated HiveType adapter. Each entry stores "
        "the raw mathematical expression, evaluated output, calculation type (basic, scientific, or financial), and an exact DateTime timestamp."
    )
    story.append(Paragraph(p_8_4, body_text))

    story.append(Paragraph("8.5 User Interface &amp; Component Layout", sub_heading))
    p_8_5 = (
        "The interface is divided into a balanced layout: a top display area showing expressions, live previews, and error alerts, "
        "and a lower grid containing color-coded, touch-friendly keypads. A smooth animated tab controller enables fluid switching "
        "between Basic, Scientific, and Advanced modes."
    )
    story.append(Paragraph(p_8_5, body_text))

    story.append(Paragraph("8.6 End-to-End System Workflow", sub_heading))
    p_8_6 = (
        "Upon app launch, Hive boxes and system orientation locks are initialized. The splash screen renders with smooth introductory animations "
        "before transitioning to the main screen. As users perform calculations, live previews update in real time. Tapping equals saves the "
        "computation to local storage and updates the history drawer."
    )
    story.append(Paragraph(p_8_6, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 16: 8. SYSTEM DESIGN & METHODOLOGY (Part 2)
    # ==========================================
    story.append(Paragraph("8.7 Software Development Life Cycle (SDLC) &amp; Agile Methodology", sub_heading))
    p_8_7 = (
        "The project followed an Agile iterative development methodology. The lifecycle was divided into five distinct two-week sprints:<br/>"
        "• <b>Sprint 1 (Requirement Analysis &amp; Prototyping):</b> Defining the feature set, designing user flows, and establishing UI wireframes.<br/>"
        "• <b>Sprint 2 (Core Engine &amp; Basic Calculator):</b> Implementing arithmetic parsing, reactive state architecture, and button interfaces.<br/>"
        "• <b>Sprint 3 (Scientific &amp; Financial Utilities):</b> Integrating scientific functions, AST evaluation, and modules for EMI, GST, Tax, Age, and BMI.<br/>"
        "• <b>Sprint 4 (Persistence, History &amp; Converters):</b> Implementing Hive database storage, the history drawer, unit converters, and live currency APIs.<br/>"
        "• <b>Sprint 5 (Optimization, Theming &amp; Testing):</b> Adding 24 custom themes, haptic touch feedback, rigorous boundary testing, and release APK/AAB packaging."
    )
    story.append(Paragraph(p_8_7, body_text))

    story.append(Paragraph("8.8 Quality Assurance, Error Handling &amp; Verification", sub_heading))
    p_8_7_b = (
        "A multi-step verification strategy was implemented to ensure mathematical precision, stability, and zero runtime crashes:<br/>"
        "• <b>Boundary Condition Verification:</b> Testing edge cases such as division by zero, square roots of negative numbers, extremely large exponents, and unbalanced parentheses.<br/>"
        "• <b>Automated Code Analysis:</b> Running <i>flutter analyze</i> to enforce strict Dart lint rules, prevent memory leaks, and maintain high code quality.<br/>"
        "• <b>Physical Device Testing:</b> Validating responsive layouts, battery usage, and haptic feedback across physical test smartphones running Android 14."
    )
    story.append(Paragraph(p_8_7_b, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 17: 9. ADVANTAGES, APPLICATIONS & FUTURE SCOPE (Part 1)
    # ==========================================
    story.append(Paragraph("<b>9.ADVANTAGES, APPLICATIONS &amp; FUTURE SCOPE</b>", main_heading))

    story.append(Paragraph("9.1 All-in-One Convenience in a Single Unified Suite", sub_heading))
    p_9_1 = (
        "CalcX Pro consolidates everyday arithmetic, scientific computing, loan analysis, tax estimation, and unit conversions into a single, "
        "lightweight application. Users no longer need to switch between multiple standalone tools."
    )
    story.append(Paragraph(p_9_1, body_text))

    story.append(Paragraph("9.2 Lightweight, Distraction-Free &amp; Privacy-Centric Architecture", sub_heading))
    p_9_2 = (
        "CalcX Pro is engineered with zero background tracking analytics and zero bloatware services. All calculations and history logs are processed and stored "
        "locally on the device, ensuring complete user privacy."
    )
    story.append(Paragraph(p_9_2, body_text))

    story.append(Paragraph("9.3 High Execution Speed and Instantaneous Response", sub_heading))
    p_9_3 = (
        "Built with Flutter’s ahead-of-time (AOT) compiled Dart code and an embedded Hive NoSQL database, the app delivers instant calculation results "
        "with zero perceptible lag."
    )
    story.append(Paragraph(p_9_3, body_text))

    story.append(Paragraph("9.4 Offline-First Reliability", sub_heading))
    p_9_4 = (
        "All core calculation modes—basic, scientific, EMI, GST, Tax, Age, BMI, and Unit conversion—operate completely offline without requiring "
        "an active network connection."
    )
    story.append(Paragraph(p_9_4, body_text))

    story.append(Paragraph("9.5 Ergonomic Multi-Theme Visual Comfort", sub_heading))
    p_9_5 = (
        "With 24 curated color palettes, quick light/dark mode toggling, and AMOLED black support, users can easily customize the app’s appearance "
        "for optimal visual contrast and reduced battery consumption."
    )
    story.append(Paragraph(p_9_5, body_text))

    story.append(Paragraph("9.6 Practical Applications for Students &amp; Educators", sub_heading))
    p_9_6 = (
        "Students and teachers can solve complex algebraic and trigonometric equations, verify homework problems, and explore unit conversions "
        "without carrying dedicated hardware calculators."
    )
    story.append(Paragraph(p_9_6, body_text))

    story.append(Paragraph("9.7 Applications for Retailers, Accountants &amp; Financial Planners", sub_heading))
    p_9_7 = (
        "Shopkeepers, small business owners, and consumers benefit from instant GST calculations, retail discounts, and loan EMI estimates "
        "without needing complex spreadsheet templates."
    )
    story.append(Paragraph(p_9_7, body_text))

    story.append(Paragraph("9.8 Applications for Everyday Health &amp; General Productivity", sub_heading))
    p_9_8 = (
        "Everyday users can calculate exact age milestones, verify BMI health classifications, and convert units during travel or cooking, "
        "making CalcX Pro an indispensable daily utility."
    )
    story.append(Paragraph(p_9_8, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 18: 9. ADVANTAGES, APPLICATIONS & FUTURE SCOPE (Part 2)
    # ==========================================
    story.append(Paragraph("9.9 Future Functional Enhancements", sub_heading))
    p_9_9 = (
        "While CalcX Pro delivers a robust set of tools, future versions can expand its capabilities even further:<br/>"
        "• <b>Camera OCR &amp; Handwriting Recognition:</b> Utilizing on-device machine learning (Google ML Kit) to scan handwritten or printed equations directly through the camera.<br/>"
        "• <b>2D / 3D Interactive Function Graphing:</b> Plotting Cartesian and polar equations (e.g., y = f(x)) with pinch-to-zoom interactive canvas exploration.<br/>"
        "• <b>Matrix Algebra &amp; Vector Mathematics:</b> Adding matrix determinants, inversions, eigenvalues, dot/cross products, and linear system solvers for advanced engineering.<br/>"
        "• <b>Exportable PDF / CSV History Reports:</b> Enabling users to export formatted calculation records for professional accounting and academic documentation."
    )
    story.append(Paragraph(p_9_9, body_text))

    story.append(Paragraph("9.10 Cross-Platform Expansion &amp; Cloud Synchronization", sub_heading))
    p_9_10 = (
        "Leveraging Flutter’s versatile codebase, CalcX Pro is positioned for broader multi-platform availability:<br/>"
        "• <b>iOS App Store Release:</b> Extending the application to iPhone and iPad devices using Apple Cupertino design guidelines.<br/>"
        "• <b>Desktop Support (Windows, macOS &amp; Linux):</b> Packaging native desktop releases with keyboard hotkey shortcuts and resizable multi-window layouts.<br/>"
        "• <b>Optional Encrypted Cloud Sync:</b> Allowing users to securely synchronize calculation history across personal devices using end-to-end encryption."
    )
    story.append(Paragraph(p_9_10, body_text))
    story.append(PageBreak())

    # ==========================================
    # PAGE 19: 10. REFERENCES
    # ==========================================
    story.append(Paragraph("<b>10. REFERENCES</b>", main_heading))

    story.append(Paragraph("10.1 Books and Academic Study Materials", sub_heading))
    p_10_1 = (
        "1. Martin, Robert C., <i>Clean Architecture: A Craftsman's Guide to Software Structure and Design</i>, Prentice Hall, 2017.<br/>"
        "2. Aho, Alfred V., Lam, Monica S., Sethi, Ravi, and Ullman, Jeffrey D., <i>Compilers: Principles, Techniques, and Tools</i> (2nd Edition), Addison-Wesley, 2006.<br/>"
        "3. Cormen, Thomas H., Leiserson, Charles E., Rivest, Ronald L., and Stein, Clifford, <i>Introduction to Algorithms</i> (3rd Edition), MIT Press, 2009."
    )
    story.append(Paragraph(p_10_1, body_text))

    story.append(Paragraph("10.2 Flutter and Dart Official Technical Documentation", sub_heading))
    p_10_2 = (
        "4. Google LLC, <i>Flutter Documentation: Architecture, State Management, and Layouts</i>, Available online at: https://flutter.dev/docs (Accessed 2026).<br/>"
        "5. Google LLC, <i>Dart Programming Language Specification and Core Libraries</i>, Available online at: https://dart.dev/guides (Accessed 2026)."
    )
    story.append(Paragraph(p_10_2, body_text))

    story.append(Paragraph("10.3 Mobile Software Engineering &amp; State Management", sub_heading))
    p_10_3 = (
        "6. Windmill, Eric, <i>Flutter in Action</i>, Manning Publications, 2020.<br/>"
        "7. Napoli, Marco L., <i>Beginning Flutter: A Hands On Guide to App Development</i>, John Wiley &amp; Sons, 2019.<br/>"
        "8. Remi Rousselet et al., <i>Provider: A wrapper around InheritedWidget to make them easier to use and more reusable</i>, pub.dev, 2024."
    )
    story.append(Paragraph(p_10_3, body_text))

    story.append(Paragraph("10.4 Mathematical Evaluation and Algorithm Literature", sub_heading))
    p_10_4 = (
        "9. Dijkstra, Edsger W., <i>Making a Translator for ALGOL 60</i>, Automatic Programming Information, Vol. 7, pp. 347–365, 1961.<br/>"
        "10. Knuth, Donald E., <i>The Art of Computer Programming, Volume 1: Fundamental Algorithms</i> (3rd Edition), Addison-Wesley, 1997."
    )
    story.append(Paragraph(p_10_4, body_text))

    story.append(Paragraph("10.5 Open-Source Frameworks, Libraries &amp; Online Resources", sub_heading))
    p_10_5 = (
        "11. Hive Database Documentation, <i>Fast, Lightweight NoSQL Database for Flutter and Dart</i>, Available at: https://docs.hivedb.dev.<br/>"
        "12. math_expressions Library Documentation, <i>A mathematical expression parser and evaluator written in Dart</i>, pub.dev.<br/>"
        "13. World Health Organization (WHO), <i>Global Database on Body Mass Index (BMI) Classification Guidelines</i>, Geneva."
    )
    story.append(Paragraph(p_10_5, body_text))

    doc.build(story)
    print("PDF build completed successfully.")

if __name__ == '__main__':
    build_pdf()
